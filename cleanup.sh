cleanup() {
    git checkout doc
    for testcase in testcase1 testcase2; do
        for branch in master branch1 branch2; do
            git branch -D "${testcase}/${branch}"
        done
    done
}

cleanup
