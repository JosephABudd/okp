# okp

**O**ne **K**ey **P**iano.

Learn to play a morse code straight key like a piano.

## Intro

This version is being done with these tools which I really like.

* [zig](https://ziglang.org/).
* [dvui](https://github.com/david-vanderson/dvui). Dave Vanderson's graphics framework for zig.
* [sqlite-zig](https://github.com/leroycep/sqlite-zig.git). LeRoyce Pearson's sqlite package for zig.
* [kickzig](https://github.com/JosephABudd/kickzig).

But before I can do that I need an audio package for the metronome clicks and for the key tone. So I'm looking into that right now.

## The Plan

### 1. Courses

In **Courses** one can

* View a description of the current course and select a different current course.
* Create a new course.
* Edit an existing course.
* Remove an existing course.

#### A course has

* A name.
* A description.
* One of the various lesson plans. A lesson plan is series of lessons. A lesson presents the character, word or sentence that one must learn to copy and key.
* One of the various speeds for keying and copying.

### 2. Training

In **Training** one learns the current course one lesson at a time. In a lesson one pratices as long as desired and then tests.

#### Copying

##### Copy Practice

* The morse code is keyed by the app.
* Correct copies don't count toward anything. Incorrect copies don't count against anything.

##### Copy Test

* The morse code is keyed by the app.
* Correct copy attempts accumulate until the required amount of correct copy attempts is reached.
* Incorrect copy attempts have no effect on the accumulated correct copy attempts.

#### Keying

##### Key Practice

* The text to be keyed is displayed.
* The keying instructions are displayed.
* The app's metronome can be turned on to keep time.
* When the metronome is turned off the key sounds in the app. The key has a subtle beat to help keep time. Hold the key down for 1 beat for a dit. Hold the key down for 3 beats for a dah.
* Correct key attempts don't count toward anything.
* Incorrect key attempts don't count against anything.

##### Key Test

* The text to be keyed is displayed.
* The keying instructions are not displayed.
* The app's metronome can not be turned on to keep time.
* The key sounds in the app. The key has a subtle beat to help keep time. Hold the key down for 1 beat for a dit. Hold the key down for 3 beats for a dah.
* Correct key attempts accumulate until the required amount of correct key attempts is reached.
* Incorrect key attempts have no effect on the accumulated correct key attempts.
