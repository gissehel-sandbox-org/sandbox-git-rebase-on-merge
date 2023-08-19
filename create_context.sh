#!/usr/bin/bash

git_bin=$(which git)
sed_bin=$(which sed)

git() {
    echo git "${@}"
    "${git_bin}" "${@}" 2>&1 | while read line ; do
        echo "    ${line}"
    done
}

sed_on_main() {
    echo sed -i "${@}" main.txt 
    "${sed_bin}" -i "${@}" main.txt 2>&1 | while read line ; do
        echo "    ${line}"
    done
}

insert_line() {
    local reference="${1}"
    local line="${2}"
    sed_on_main "/^REFERENCE LINE X${reference}/a ${line}"
}

create_commit() {
    local testcase="${1}"
    local commit_letter="${2}"
    local references="${3}"
    local branch="${4}"
    git checkout "${testcase}/${branch}"
    for reference in ${references}; do
        insert_line "${reference}" "COMMIT ${commit_letter}"
    done
    git add main.txt
    git commit -m "COMMIT ${commit_letter}"
}

create_branch() {
    local testcase="${1}"
    local from_branch="${2}"
    local branch="${3}"

    [ -n "${from_branch}" ] && git checkout "${testcase}/${from_branch}"
    git branch "${testcase}/${branch}"
}

merge_branch() {
    local testcase="${1}"
    local from_branch="${2}"
    local branch="${3}"
    local commit_letter="${4}"
    local reference="${5}"
    local sed_command_to_fix_conflict="${6}"

    git checkout "${testcase}/${from_branch}"
    git merge "${testcase}/${branch}" --no-commit
    insert_line "${reference}" "COMMIT ${commit_letter}"
    [ -n "${sed_command_to_fix_conflict}" ] && sed_on_main "${sed_command_to_fix_conflict}"
    git add main.txt
    git commit -m "COMMIT ${commit_letter}"
}

testcase1() {
    local testcase="testcase1"
    git checkout doc
    create_branch "${testcase}" "" "master"
    create_commit "${testcase}" "A" "001" "master"
    create_commit "${testcase}" "B" "002" "master"
    create_branch "${testcase}" "master" "branch_1"
    create_commit "${testcase}" "C" "003" "branch_1"
    create_branch "${testcase}" "branch_1" "branch_2"
    create_commit "${testcase}" "D" "004" "master"
    create_commit "${testcase}" "E" "005" "branch_1"
    create_commit "${testcase}" "F" "006" "branch_2"
    merge_branch "${testcase}" "branch_1" "branch_2" "G" "007"
}

testcase2() {
    local testcase="testcase2"
    git checkout doc
    create_branch "${testcase}" "" "master"
    create_commit "${testcase}" "A" "001" "master"
    create_commit "${testcase}" "B" "002" "master"
    create_branch "${testcase}" "master" "branch_1"
    create_commit "${testcase}" "C" "003" "branch_1"
    create_branch "${testcase}" "branch_1" "branch_2"
    create_commit "${testcase}" "D" "004" "master"
    create_commit "${testcase}" "E" "005 007" "branch_1"
    create_commit "${testcase}" "F" "006 007" "branch_2"
    merge_branch "${testcase}" "branch_1" "branch_2" "G" "007" "14,18d"
}

testcase1
testcase2
