#!/usr/bin/env python3
# space merge 2
# run from git root, don't interrupt or files will corrupt.
# if failure does happen, rerun in place- it will clean up and start fresh.
# automates as much as possibly can be.

# imports - may need to pip install GitPython for git library

import argparse
import datetime
import git
import os
import re
import subprocess as sp
import sys

# config/globals

# i don't exepct these to get modified, but this avoids littering hard code
upstream = "tgstation"
upstream_branch = upstream + "/master"
their_dme = "tgstation.dme"
our_dme = "RussStation.dme"
epoch_path = "last_merge"
build_path = "tools/build/build.js"
# files to skip parsing and take ours or theirs
ours = ["html/changelog.html",
        "html/changelogs/.all_changelog.yml",
        "html/templates/header.html",
        "README.md",
        ".travis.yml",
        ".github/ISSUE_TEMPLATE/bug_report.md",
        ".github/ISSUE_TEMPLATE/feature_request.md"]
theirs = [".gitattributes", # we actually handle .gitattributes special to avoid problems, but listed here for clarity
          ".editorconfig",
          "tgstation.dme"]
# dirs processed after individual files
our_dirs = [".github",
            "config",
            "russstation"]
their_dirs = ["_maps",
              "icons",
              "interface",
              "sound",
              "SQL",
              "tgui",
              "tools"]
# binary files break the parser so please exclude them
binaries = ["*.dmm",
            "*.dmi",
            "*.dll",
            "*.ogg",
            "*.exe",
            "*.jar",
            "*.png"]
sha1_check = re.compile(r"^[0-9a-f]{40}")
honk_check = re.compile(r"((//|\\\\|/\*).*?honk|honk.*?\*/)", re.IGNORECASE) # why are // and \\ both legal comments in DM
include_find = re.compile(r'#include\s*"(.*?)"')
verbose = False # i don't want to pass this around everywhere >:(

# functions

# for verbose printing
def printv(*args):
    if verbose:
        print(*args)

# fancy command line interface~
def get_args():
    parser = argparse.ArgumentParser(
        description = "Simplify merging upstream SS13 repository"
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Print more detail about script operation"
    )
    parser.add_argument(
        "-f", "--file",
        help="Process a single file"
    )
    return parser.parse_args()

# get a clean branch off master, fetch
def prepare_branch(repo):
    print("Preparing merge branch...")
    # GitPython doesn't support all the flags so the repo.git calls are "manual" operations
    name = "upstream-merge-" + datetime.datetime.now().strftime("%y%m%d")
    repo.head.reset(working_tree=True)
    repo.git.clean("-f", "-d", "-x")
    printv("Cleaned index")
    # couldn't find option for fetch all, just get the ones we care about
    repo.remotes.origin.fetch()
    repo.remotes[upstream].fetch()
    printv("Fetched origin and upstream")
    if not name in repo.heads:
        repo.create_head(name, repo.heads.master) # maybe should be repo.remotes.origin.refs.master
        printv("Created branch", name)
    repo.heads[name].set_tracking_branch(repo.remotes.tgstation.refs.master)
    repo.heads[name].checkout()
    printv("Checked out branch", name)

# get time as a unix epoch, doesn't need quoted
def get_last_merge(repo):
    # the "smart" solution is wrong, because the timestamp will reflect the time of PR merge:
    #     return repo.git.log("-1", "--format=%ct", their_dme)
    # instead store the actual epoch of last merge so that it's guaranteed to be accurate
    current_merge = str(datetime.datetime.now().timestamp())
    with open(epoch_path, "r") as file:
        last_merge = file.readline().strip()
        printv("Last merge was", last_merge, datetime.datetime.fromtimestamp(int(last_merge)).strftime("%c"))
        return (last_merge, current_merge) # get current merge to commit later

# counterpart to get, wait until after merge to add the file change
def update_last_merge(repo, current_merge):
    # update merge tracking file
    with open(epoch_path, "w") as file:
        file.write(current_merge)
    repo.git.add(epoch_path)
    printv("Updated merge to", current_merge)

# hopefully this reduces how much needs processed
def merge_upstream(repo):
    print("Merging...")
    try:
        repo.git.merge(upstream_branch, "-Xignore-space-at-eol", "-Xdiff-algorithm=minimal", "--squash", "--allow-unrelated-histories")
    except git.exc.GitCommandError as e:
        # expected because the merge will have conflicts; rfind because it'll be near the end of the giant error text
        if repr(e).rfind("fix conflicts") == -1:
            raise e

# fix .git files immediately
def prepare_git_files(repo):
    # .gitattributes just check if it's modified, then we'll take theirs
    if repo.git.status("-s", ".gitattributes"):
        repo.git.checkout(".gitattributes", "--theirs")
        repo.git.add(".gitattributes")
        printv("Checked out their .gitattributes")
    # .gitignore take theirs then append ours
    if repo.git.status("-s", ".gitignore"):
        repo.git.checkout(".gitignore", "--theirs")
        printv("Checked out their .gitignore")
        with open("our.gitignore", "r") as ours, open(".gitignore", "a") as theirs:
            line = ours.readline()
            while line:
                theirs.write(line)
                line = ours.readline()
        repo.git.add(".gitignore")
        printv("Appended our.gitignore")

# handle some stuff before process loop so it's a bit msmoother
def preprocess_diffs(repo):
    print("Checking out files that don't need processed...")
    for filename in ours:
        repo.git.checkout(filename, "--ours")
        repo.git.add(filename)
        printv("Checked out our", filename)
    for filename in theirs:
        repo.git.checkout(filename, "--theirs")
        repo.git.add(filename)
        printv("Checked out their", filename)
    for dirname in our_dirs:
        repo.git.checkout(dirname, "--ours")
        repo.git.add(dirname)
        printv("Checked out our", dirname + "/")
    for dirname in their_dirs:
        repo.git.checkout(dirname, "--theirs")
        repo.git.add(dirname)
        printv("Checked out their", dirname + "/")
    for ext in binaries:
        repo.git.checkout(ext, "--theirs")
        repo.git.add(ext)
        printv("Checked out their", ext)

# get a list of files that were updated upstream
def get_upstream_updated_paths(repo, last_merge):
    print("Retrieving updated file list...")
    long_paths = repo.git.log("--after=" + last_merge, "--remotes=" + upstream, "--name-only", "--pretty=oneline")
    # raw output contains duplicates and lines starting with the commit hash, we don't want those
    only_paths = [path for path in long_paths.splitlines() if path and not sha1_check.match(path)]
    updated_paths = set(only_paths)
    printv(len(updated_paths), "files updated since last merge")
    return updated_paths

# find conflict section, inspect section based on rules, modify file, stage in git
def fix_conflicts(repo, filename):
    stage = True
    temp_filename = filename + ".temp"
    with open(filename, "r") as conflict_file, open(temp_filename, "w") as processed_file:
        text_line = conflict_file.readline()
        while text_line:
            # parse for conflict section
            if text_line.startswith("<<<<<<<"):
                ours_buffer = [text_line] # init buffer with current line for leaving section
                # found head of conflict, grab until diff divider
                contains_honk = False
                text_line = conflict_file.readline()
                while not text_line.startswith("======="):
                    ours_buffer.append(text_line)
                    # check for honk comment presence in this section - re.search instead of .match to check entire string
                    if not contains_honk and honk_check.search(text_line):
                        contains_honk = True
                        stage = False
                        break
                    text_line = conflict_file.readline()
                # if we found a match, print entire conflict for manual resolution
                if contains_honk:
                    for line in ours_buffer:
                        processed_file.write(line)
                    # manually continue outer loop, it will print remaining lines
                    text_line = conflict_file.readline()
                    continue
                else:
                    text_line = conflict_file.readline() # toss === line
                    # no honk found, replace ours with theirs
                    while not text_line.startswith(">>>>>>>"):
                        processed_file.write(text_line)
                        text_line = conflict_file.readline()
                    # manually continue loop, skipping the >>> line
                    text_line = conflict_file.readline()
                    continue
            # parsing finished, add line to file and continue
            processed_file.write(text_line)
            text_line = conflict_file.readline()
    # replace file with processed
    os.replace(temp_filename, filename)
    # mark staged in git
    if stage:
        repo.git.add(filename)
        printv("Staged", filename)
    else:
        printv("Conflict found in", filename)

# get conflicted files, process em, revert unchanged conflicts
def process_diffs(repo, last_merge):
    # according to docs this is how to get our current changes i guess
    #dirty_files = repo.index.diff(repo.head.commit)
    dirty_paths = repo.git.diff("--name-only", "--diff-filter=U").splitlines()
    printv(len(dirty_paths), "files staged or unmerged")
    # only process files that were changed upstream - skips files with conflicts we've previously solved
    upstream_paths = get_upstream_updated_paths(repo, last_merge)
    revert_paths = []
    print("Processing files...")
    #for file in dirty_files:
    for path in dirty_paths:
        #path = file.a_path
        valid = path in upstream_paths
        # order of checks tries to avoid processing or reverting the wrong files
        #if file.change_type != "U":
            # only concerned with conflicted files, merge should have handled the rest
        #    pass
        #el
        if not valid:
            # not a new file change, revert
            revert_paths.append(path)
        else:
            # must be conflicted and worth merging, try to fix it
            try:
                fix_conflicts(repo, path)
            except:
                printv("Failed processing on", path)
                printv("Exception:", sys.exc_info())
    print("Reverting unchanged files...")
    printv(len(revert_paths), "unchanged files to revert")
    for path in revert_paths:
        try:
            # why doesn't git have a single operation for unstage and discard
            printv("Reverting", repo.git.status("-s", path))
            repo.git.restore(path, "--staged")
            repo.git.restore(path)
        except git.exc.GitCommandError as e:
            # git restore fails if file doesn't exist because it was git removed
            printv("Couldn't revert", path)
            printv(repr(e))

# upstream builds via node instead of just dreammaker now, so make our own copy of that
def update_build_script(repo):
    print("Updating build script...")
    repo.git.checkout(build_path, "--theirs") # ensure we're not starting with a conflicted file
    content = None
    with open(build_path, "rt") as build_file:
        content = build_file.read()
    with open(build_path, "wt") as build_file:
    # replace the convenient variable that doesn't have the .dme suffix (and reuse config strings? ¯\_(ツ)_/¯)
        build_file.write(content.replace("DME_NAME = '" + their_dme[:their_dme.find(".")], "DME_NAME = '" + our_dme[:our_dme.find(".")]))
    repo.git.add(build_path)
    printv("Updated build script at", build_path)

# get unique includes from both dmes, combine
def update_includes(repo):
    preface = []
    their_includes = []
    our_includes = []
    print("Updating DME includes...")
    with open(their_dme, "r") as their_file:
        # get their includes
        text_line = their_file.readline()
        while text_line:
            # skip until includes
            if include_find.match(text_line):
                break
            else:
                text_line = their_file.readline()
        while text_line:
            match = include_find.match(text_line)
            if match:
                their_includes.append(match.group(1).strip())
                text_line = their_file.readline()
            else:
                break
    printv(len(their_includes), "their includes")
    with open(our_dme, "r") as our_file:
        # get our includes
        text_line = our_file.readline()
        while text_line:
            # store lines before includes to rebuild file
            match = include_find.match(text_line)
            if match:
                break
            else:
                preface.append(text_line)
                text_line = our_file.readline()
        while text_line:
            match = include_find.match(text_line)
            if match:
                our_includes.append(match.group(1).strip())
                text_line = our_file.readline()
            else:
                break
    printv(len(our_includes), "our includes")
    # combine without dupes, remove files that don't exist (leftover in our dme)
    new_includes = []
    for path in set(their_includes + our_includes):
        if os.path.isfile(path.replace("\\", "/")): # stupid wrong slashes
            new_includes.append(path)
    new_includes.sort()
    printv(len(new_includes), "combined includes")
    # write file beginning then includes
    with open(our_dme, "w") as file:
        for line in preface:
            file.write(line)
        for path in new_includes:
            file.write('#include "' + path + '"\n')
        file.write("// END_INCLUDE\n")
    repo.git.add(our_dme)

# files will sneak past the .gitignore because git merge uses the wrong .gitignore before we can fix it
def check_ignored(repo):
    # have to do this with subprocess because gitpython doesn't have piping and the first result is too big to pass
    staged_files = sp.Popen(["git", "diff", "--name-only", "--cached"], text=True, stdout=sp.PIPE)
    ignored_files = sp.Popen(["git", "check-ignore", "--stdin", "--no-index"], text=True, stdin=staged_files.stdout, stdout=sp.PIPE)
    staged_files.wait()
    ignored_files.wait()
    ignored_paths, stderr = ignored_files.communicate()
    if len(ignored_paths):
        print("Unstaging files that evaded .gitignore...")
        for path in ignored_paths.splitlines():
            if path:
                repo.git.rm("--cached", path)
                printv(path, "removed from index")

# say anything that still needs said
def finish(repo):
    remaining_conflicts = repo.git.diff("--name-only", "--diff-filter=U").splitlines()
    print("Merge completed, manually review", len(remaining_conflicts), "remaining conflicts")
    if verbose:
        # show conflicted files. not using printv because why loop the list in non-verbose mode?
        for path in remaining_conflicts:
            print(path)

# run the dang script
if __name__ == "__main__":
    args = get_args()
    repo = git.Repo(os.getcwd())
    verbose = args.verbose
    # check we're running at git root
    if not repo or repo.bare:
        print("Script must be run from git root")
    elif args.file:
        # single file testing
        fix_conflicts(repo, args.file)
    else:
        prepare_branch(repo)
        last_merge, current_merge = get_last_merge(repo) # grab time before merge for accuracy
        merge_upstream(repo)
        prepare_git_files(repo)
        update_last_merge(repo, current_merge)
        preprocess_diffs(repo)
        process_diffs(repo, last_merge)
        update_build_script(repo)
        update_includes(repo)
        check_ignored(repo)
        finish(repo)
