# Notez (with a Z)

A note taking app for neovim. Files are markdown files.

Very early stages. Not ready for use. More documentation to come.

Best used with other plugins like:

* telescope
* render-markdown
* follow-md-links


## Installation

### neovim 0.12+

With native plugin management:

    vim.pack.add('https://github.com/mshiltonj/notezwithaz.nvim')
    
    require("notez").setup({
    
    })

Config settings to be determined:

* Notez data location
* Day of week start (Sunday or Monday)
* What else?


## The plan

User's should be be able to define their own templates for different types of notes, or use plugin defaults:

* Daily note
* Weekly note
* General note
* Meeting note
* Project note


I want to add functionality for:

    :Notez foobar

Edit or create a new general note. Using the note template, and creating as markdown fil.

    :Notez today

Edit today's daily note

    :Notez tomorrow

Edit tomorrow's daily note

    :Notez yesterday

Edit yesterday's daily note

    :Notez -f

Edit most recent Friday's daily note

    :Notez f

Edit upcoming Friday's daily note

    :Notez m

Edit upcoming Monday's daily note

    :Notez -m

Edit last Monday's daily note

    :Notez week

Edit this week's weekly note

    :Notez lastweek

Edit last week's weekly note

    :Notez nextweek

Edit next week's weekly note

    :Notez cal

A popup window showing a date selector to natigate to a specific date's not. I'm not sure if this is necessary. May telescope is better suited for finding files.

    :Notez todo

A popup window showing a global TODO list


