# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands to run in this directory

### Run specs
export PATH="/usr/local/opt/ruby/bin:/Users/michaelfeathers/.gem/ruby/3.4.0/bin:$PATH" && bundle exec rspec

### Run a single spec
export PATH="/usr/local/opt/ruby/bin:/Users/michaelfeathers/.gem/ruby/3.4.0/bin:$PATH" && bundle exec rspec spec/path/to/specific_spec.rb

### Run the main application
ruby bin/todo

### Run with headless mode (no console output)
ruby bin/todo headless

### Install dependencies
bundle install

## Architecture Overview

This is a Ruby-based todo list application with a command-driven interface. The system supports two types of task lists: foreground tasks and background tasks.

### Core Components

- **Executable** (`bin/todo`): Entry point that handles lock file management and launches the application
- **ToDo** (`todo.rb`): Main application class that manages command execution and the main run loop
- **Session** (`lib/session.rb`): Manages the session state, including foreground/background task lists and command logging
- **TaskList** (`lib/tasklist.rb`): Handles task list operations (add, remove, edit, search, etc.)
- **Command System**: Each command is implemented as a separate class in `lib/commands/` inheriting from `Command`

### Command Architecture

Commands are implemented using a plugin-like architecture:
- Each command inherits from `Command` class (`lib/command.rb`)
- Commands must implement `matches?(line)` to check if they handle a given input
- Commands implement `process(line, session)` to execute their functionality
- All commands are auto-loaded from `lib/commands/` via `lib/commands.rb`
- All commands are registered in `ToDo.registered_commands` (`todo.rb:13-51`)

### Data Storage

- Tasks are stored in plain text files via IO classes (`lib/appio.rb`, `lib/backgroundio.rb`, `lib/headlessio.rb`)
- Archive data is maintained for completed tasks
- Command usage statistics are tracked in a log file

### Key Features

- **Dual Lists**: Foreground and background task lists with ability to switch between them
- **Task Movement**: Move tasks between lists or reorder within lists
- **Search**: Global find across both lists, iterative find within current list
- **Tagging**: Tasks can be tagged with categories (format: "TAG: task description")
- **Archiving**: Completed tasks are saved to archive with timestamps
- **Reporting**: Various reports including trends, summaries, and tag tallies
- **Command Logging**: Tracks usage frequency of different commands

### Testing

Tests are located in `spec/` directory using RSpec. Each command has its own test file following the pattern `*_spec.rb`. The test setup uses SimpleCov for coverage reporting.