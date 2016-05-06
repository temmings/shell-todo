#!/bin/bash

setUp() {
    TODO_FILE=$(mktemp $SHUNIT_TMPDIR/$(basename $0).XXXXX)
    TODO_FILE_BACKUP_EXT=backup_ext
    source $(dirname $0)/shell-todo
}

tearDown() {
    rm -f $TODO_FILE $TODO_FILE.$TODO_FILE_BACKUP_EXT
}

test_todo_swapfile() {
    local file1 file2
    file1=$(mktemp $SHUNIT_TMPDIR/$(basename $0).XXXXX)
    file2=$(mktemp $SHUNIT_TMPDIR/$(basename $0).XXXXX)
    echo file 1 > $file1
    echo file 2 > $file2
    _todo_swapfile $file1 $file2 > /dev/null
    assertEquals 'file 1' "$(cat $file2)"
    assertEquals 'file 2' "$(cat $file1)"
    rm $file1 $file2
}

test_todo_add() {
    _todo_add 'test add todo' > /dev/null
    assertEquals "test add todo" "$(tail -1 $TODO_FILE)"
    _todo_add test unquoted todo > /dev/null
    assertEquals "test unquoted todo" "$(tail -1 $TODO_FILE)"
}

test_todo_show() {
    assertNull "$(_todo_show)"
    _todo_add 'test show todo 1' > /dev/null
    _todo_add 'test show todo 2' > /dev/null
    _todo_add 'test show todo 3' > /dev/null
    local result
    result=$(_todo_show)
    assertTrue '[[ "$result" =~ "test show todo 1" ]]'
    assertTrue '[[ "$result" =~ "test show todo 2" ]]'
    assertTrue '[[ "$result" =~ "test show todo 3" ]]'
}

test_todo_backup() {
    _todo_add 'test backup todo' > /dev/null
    _todo_backup > /dev/null
    assertEquals "test backup todo" "$(tail -1 $TODO_FILE.$TODO_FILE_BACKUP_EXT)"
    assertEquals "$(cat $TODO_FILE)" "$(cat $TODO_FILE.$TODO_FILE_BACKUP_EXT)"
}

test_todo_delete() {
    _todo_add 'test delete todo' > /dev/null
    _todo_add 'test delete todo 2' > /dev/null
    (_todo_delete 2 > /dev/null)
    assertEquals "test delete todo" "$(tail -1 $TODO_FILE)"
    (_todo_delete 1 > /dev/null)
    assertNull "Todo is not empty" "$(tail -1 $TODO_FILE)"
}

test_todo_undo() {
    _todo_add 'test undo todo' > /dev/null
    _todo_add 'test redo todo' > /dev/null
    _todo_undo > /dev/null
    assertEquals "test undo todo" "$(tail -1 $TODO_FILE)"
    _todo_undo > /dev/null
    assertEquals "test redo todo" "$(tail -1 $TODO_FILE)"
}

test_todo_delete_include_redirect() {
    _todo_add 'default todo' > /dev/null
    _todo_add 'include > greater than' > /dev/null
    _todo_add 'include < less than' > /dev/null
    (_todo_delete 3 > /dev/null)
    (_todo_delete 2 > /dev/null)
    assertEquals "default todo" "$(tail -1 $TODO_FILE)"
}

SHUNIT_PARENT=$0
source $(dirname $0)/shunit2-2.1.6/src/shunit2
