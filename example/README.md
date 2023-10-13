# Todo App

An example Flutter project, utilizing the treap package to handle version history.

You can add new tasks with the floating action button, mark them as completed by 
checking the tick mark, remove them by swiping, and edit on a separate page after 
tapping them.

On the main page, you can toggle whether to see competed tasks or not, and easily
switch between version, using the undo, redo buttons, or the history slider.

The interesting bit is the way it uses treaps to maintain history, with full undo 
and redo, as well as animate between different list states. 

I deliberately kept the dependencies of this app to a minimum, ie. it only depends 
on the treap package. In particular it lacks the state and dependency management 
of a real app (ie. bloc pattern or provider/riverpod), and rely on just `setState`.

## Outline

### Task

The stuff that needs done. Implemented as an immutable value object. Not much of 
interest here.

### TodoList

Maintains two treaps (sets) of tasks; _all_ and _uncompleted_. This is also immutable. 
Handles the _transaction_ of updating both _all_ and _uncompleted_, as tasks are 
added, updated (`addOrUpdate`), or removed (`removed`)
.
### History

Manage a historic stack of todo lists, with methods such as `undo`, `redo`, and `change`.  

### TaskListPage

Basically wraps an AnimatedList. The interesting bit is in the method `_updateList`
that uses treap difference (set minus) to calculate what needs to be added/removed. 


