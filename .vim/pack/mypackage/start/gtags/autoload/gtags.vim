" File: gtags.vim
" Author: Tama Communications Corporation
" Version: 0.6.8
" Last Modified: Nov 9, 2015
"
" Copyright and license
" ---------------------
" Copyright (c) 2004, 2008, 2010, 2011, 2012, 2014, 2015
" Tama Communications Corporation
"
" This file is part of GNU GLOBAL.
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
" 
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
" 
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.
"
" Overview
" --------
" The gtags.vim plug-in script integrates the GNU GLOBAL source code tagging system
" with Vim. About the details, see http://www.gnu.org/software/global/.
"
" Installation
" ------------
" Drop the file in your plug-in directory or source it from your vimrc.
" To use this script, you need GLOBAL-6.0 or later installed in your machine.
"
" Usage
" -----
" First of all, you must execute gtags(1) at the root of source directory
" to make tag files. Assuming that your source directory is '/var/src',
" it is necessary to execute the following commands.
"
"	$ cd /var/src
"	$ gtags
"
" And you will find three tag files in the directory.
"
"	$ ls G*
"	GPATH	GRTAGS	GTAGS
"
" General form of Gtags command is as follows:
"
"	:Gtags [option] pattern
"
" You can use all options of global(1) except for the -c, -p, -u and
" all long name options. They are sent to global(1) as is.
"
" To go to 'func', you can say
"
"       :Gtags func
"
" Input completion is available. If you forgot the name of a function
" but recall only some characters of the head, please input them and
" press <TAB> key.
"
"       :Gtags fu<TAB>
"       :Gtags func			<- Vim will append 'nc'.
"
" If you omitted an argument, vim ask it as follow:
"
"       Gtags for pattern: <current token>
"
" Inputting 'main' to the prompt, vim executes `global -x main',
" parse the output, list located objects in the quickfix window
" and load the first entry. The quickfix window shows like this:
"
"      gozilla/gozilla.c|200| main(int argc, char **argv)
"      gtags-cscope/gtags-cscope.c|124| main(int argc, char **argv)
"      gtags-parser/asm_scan.c|2056| int main()
"      gtags-parser/gctags.c|157| main(int argc, char **argv)
"      gtags-parser/php.c|2116| int main()
"      gtags/gtags.c|152| main(int argc, char **argv)
"      [Quickfix List]
"
" You can go to any entry using quickfix command.
"
" :cn'
"      go to the next line.
"
" :cp'
"      go to the previous line.
"
" :ccN'
"      go to the Nth line.
"
" :cl'
"      list all lines.
"
" You can see a help for quickfix like this:
"
"          :h quickfix
"
" You can use POSIX regular expression too. It requires more execution time though.
"
"       :Gtags ^[sg]et_
"
" It will match to both of 'set_value' and 'get_value'.
"
" To go to the referenced point of 'func', add -r option.
"
"       :Gtags -r func
"
" To go to any symbols which are not defined in GTAGS, try this.
"
"       :Gtags -s func
"
" To go to any string other than symbol, try this.
"
"       :Gtags -g ^[sg]et_
"
" This command accomplishes the same function as grep(1) but is more convenient
" because it retrieves an entire directory structure.
"
" To get list of objects in a file 'main.c', use -f command.
"
"       :Gtags -f main.c
"
" If you are editing `main.c' itself, you can use '%' instead.
"
"       :Gtags -f %
"
" You can get a list of files whose path include specified pattern.
" For example:
"
"       :Gtags -P /vm/			<- all files under 'vm' directory.
"       :Gtags -P \.h$			<- all include files.
"	:Gtags -P init			<- all paths includes 'init'
"
" If you omitted an argument and input only <ENTER> key to the prompt,
" vim shows list of all files in the project.
"
" Since all short options are sent to global(1) as is, you can 
" use the -i, -o, -O, and so on.
" 
" For example, if you want to ignore case distinctions in pattern.
"
"       :Gtags -gi paTtern
"
" It will match to both of 'PATTERN' and 'pattern'.
"
" If you want to search a pattern which starts with a hyphen like '-C'
" then you can use the -e option like grep(1).
"
"	:Gtags -ge -C
"
" By default, Gtags command search only in source files. If you want to
" search in both source files and text files, or only in text files then
"
"	:Gtags -go pattern		# both source and text
"	:Gtags -gO pattern		# only text file
"
" See global(1) for other options.
"
" The Gtagsa (Gtags + append) command is almost the same as Gtags command.
" But it differs from Gtags in that it adds the results to the present list.
" If you want to get the union of ':Gtags -d foo' and ':Gtags -r foo' then
" you can invoke the following commands:
"
"       :Gtags  -d foo
"       :Gtagsa -r foo
"
" The GtagsCursor command brings you to the definition or reference of
" the current token. If it is a definition, you are taken to the references.
" If it is a reference, you are taken to the definitions.
"
"       :GtagsCursor
"
" If you have the hypertext generated by htags(1) then you can display
" the same place on mozilla browser. Let's load mozilla and try this:
"
"       :Gozilla
"
" If you want to load vim with all main()s then following command line is useful.
"
"	% vim '+Gtags main'
"
" Also see the chapter of 'vim editor' of the on-line manual of GLOBAL.
"
"	% info global
"
" The following custom variables are available.
"
" Gtags_VerticalWindow    open windows vitically
" Gtags_Auto_Map          use a suggested key-mapping
" Gtags_Auto_Update       keep tag files up-to-date automatically
" Gtags_No_Auto_Jump      don't jump to the first tag at the time of search
" Gtags_Close_When_Single close quickfix windows in case of single tag
"
" You can use the variables like follows:
"
"	[$HOME/.vimrc]
"	let Gtags_Auto_Map = 1
"
" If you want to use the tag stack, please use gtags-cscope.vim.
" You can use the plug-in together with this script.
"
if exists("loaded_gtags")
    finish
endif

"
" global command name
"
let s:global_command = $GTAGSGLOBAL
if s:global_command == ''
        let s:global_command = "global"
endif
" Open the Gtags output window.  Set this variable to zero, to not open
" the Gtags output window by default.  You can open it manually by using
" the :cwindow command.
" (This code was derived from 'grep.vim'.)
if !exists("g:Gtags_OpenQuickfixWindow")
    let g:Gtags_OpenQuickfixWindow = 1
endif

if !exists("g:Gtags_VerticalWindow")
    let g:Gtags_VerticalWindow = 0
endif

if !exists("g:Gtags_Auto_Map")
    let g:Gtags_Auto_Map = 0
endif

if !exists("g:Gtags_Auto_Update")
    let g:Gtags_Auto_Update = 0
endif

" 'Dont_Jump_Automatically' is deprecated.
if !exists("g:Gtags_No_Auto_Jump")
    if !exists("g:Dont_Jump_Automatically")
	let g:Gtags_No_Auto_Jump = 0
    else
	let g:Gtags_No_Auto_Jump = g:Dont_Jump_Automatically
    endif
endif

if !exists("g:Gtags_Close_When_Single")
    let g:Gtags_Close_When_Single = 0
endif

" -- ctags-x format 
" let Gtags_Result = "ctags-x"
" let Gtags_Efm = "%*\\S%*\\s%l%\\s%f%\\s%m"
"
" -- ctags format 
" let Gtags_Result = "ctags"
" let Gtags_Efm = "%m\t%f\t%l"
"
" Gtags_Use_Tags_Format is obsoleted.
if exists("g:Gtags_Use_Tags_Format")
    let g:Gtags_Result = "ctags"
    let g:Gtags_Efm = "%m\t%f\t%l"
endif
if !exists("g:Gtags_Result")
    let g:Gtags_Result = "ctags-mod"
endif
if !exists("g:Gtags_Efm")
    let g:Gtags_Efm = "%f\t%l\t%m"
endif
" Character to use to quote patterns and file names before passing to global.
" (This code was drived from 'grep.vim'.)
if !exists("g:Gtags_Shell_Quote_Char")
    if has("win32") || has("win16") || has("win95")
        let g:Gtags_Shell_Quote_Char = '"'
    else
        let g:Gtags_Shell_Quote_Char = "'"
    endif
endif
if !exists("g:Gtags_Single_Quote_Char")
    if has("win32") || has("win16") || has("win95")
        let g:Gtags_Single_Quote_Char = "'"
        let g:Gtags_Double_Quote_Char = '\"'
    else
        let s:sq = "'"
        let s:dq = '"'
        let g:Gtags_Single_Quote_Char = s:sq . s:dq . s:sq . s:dq . s:sq
        let g:Gtags_Double_Quote_Char = '"'
    endif
endif

"
" Display error message.
"
function! s:Error(msg)
    echohl WarningMsg |
           \ echomsg 'Error: ' . a:msg |
           \ echohl None
endfunction
"
" Extract pattern or option string.
"
function! s:Extract(line, target)
    let l:option = ''
    let l:pattern = ''
    let l:force_pattern = 0
    let l:length = strlen(a:line)
    let l:i = 0

    " skip command name.
    if a:line =~# '^Gtags'
        let l:i = 5
    endif
    while l:i < l:length && a:line[l:i] == ' '
       let l:i = l:i + 1
    endwhile 
    while l:i < l:length
        if a:line[l:i] == "-" && l:force_pattern == 0
            let l:i = l:i + 1
            " Ignore long name option like --help.
            if l:i < l:length && a:line[l:i] == '-'
                while l:i < l:length && a:line[l:i] != ' '
                   let l:i = l:i + 1
                endwhile 
            else
                while l:i < l:length && a:line[l:i] != ' '
                    let l:c = a:line[l:i]
                    let l:option = l:option . l:c
                    let l:i = l:i + 1
                endwhile 
                if l:c ==# 'e'
                    let l:force_pattern = 1
                endif
            endif
        else
            let l:pattern = ''
            " allow pattern includes blanks.
            while l:i < l:length
                 if a:line[l:i] == "'"
                     let l:pattern = l:pattern . g:Gtags_Single_Quote_Char
                 elseif a:line[l:i] == '"'
                     let l:pattern = l:pattern . g:Gtags_Double_Quote_Char
                 else
                     let l:pattern = l:pattern . a:line[l:i]
                 endif
                let l:i = l:i + 1
            endwhile 
            if a:target == 'pattern'
                return l:pattern
            endif
        endif
        " Skip blanks.
        while l:i < l:length && a:line[l:i] == ' '
               let l:i = l:i + 1
        endwhile 
    endwhile 
    if a:target == 'option'
        return l:option
    endif
    return ''
endfunction

"
" Trim options to avoid errors.
"
function! s:TrimOption(option)
    let l:option = ''
    let l:length = strlen(a:option)
    let l:i = 0

    while l:i < l:length
        let l:c = a:option[l:i]
        if l:c !~# '[cenpquv]'
            let l:option = l:option . l:c
        endif
        let l:i = l:i + 1
    endwhile
    return l:option
endfunction

"
" Execute global and load the result into quickfix window.
"
function! s:ExecLoad(option, long_option, pattern, flags)
    " Execute global(1) command and write the result to a temporary file.
    let l:isfile = 0
    let l:option = ''
    let l:result = ''

    if a:option =~# 'f'
        let l:isfile = 1
        if filereadable(a:pattern) == 0
            call s:Error('File ' . a:pattern . ' not found.')
            return
        endif
    endif
    if a:long_option != ''
        let l:option = a:long_option . ' '
    endif
    let l:option = l:option . '--result=' . g:Gtags_Result . ' -q'
    let l:option = l:option . s:TrimOption(a:option)
    if l:isfile == 1
        let l:cmd = s:global_command . ' ' . l:option . ' ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char
    else
        let l:cmd = s:global_command . ' ' . l:option . 'e ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char 
    endif

    let l:result = system(l:cmd)
    if v:shell_error != 0
        if v:shell_error != 0
            if v:shell_error == 2
                call s:Error('invalid arguments. please use the latest GLOBAL.')
            elseif v:shell_error == 3
                call s:Error('GTAGS not found.')
            else
                call s:Error('global command failed. command line: ' . l:cmd)
            endif
        endif
        return
    endif
    if l:result == '' 
        if l:option =~# 'f'
            call s:Error('Tag not found in ' . a:pattern . '.')
        elseif l:option =~# 'P'
            call s:Error('Path which matches to ' . a:pattern . ' not found.')
        elseif l:option =~# 'g'
            call s:Error('Line which matches to ' . a:pattern . ' not found.')
        else
            call s:Error('Tag which matches to ' . g:Gtags_Shell_Quote_Char . a:pattern . g:Gtags_Shell_Quote_Char . ' not found.')
        endif
        return
    endif

    " Open the quickfix window
    if g:Gtags_OpenQuickfixWindow == 1
	let l:open = 1
        if g:Gtags_Close_When_Single == 1
	    let l:open = 0
	    let l:idx = stridx(l:result, "\n")
	    if l:idx > 0 && stridx(l:result, "\n", l:idx + 1) > 0
		let l:open = 1
	    endif
	endif
	if l:open == 0
	    cclose
        elseif g:Gtags_VerticalWindow == 1
            topleft vertical copen
        else
            botright copen
        endif
    endif
    " Parse the output of 'global -x or -t' and show in the quickfix window.
    let l:efm_org = &efm
    let &efm = g:Gtags_Efm
    if a:flags =~# 'a'
        cadde l:result		" append mode
    elseif g:Gtags_No_Auto_Jump == 1
        cgete l:result		" does not jump
    else
        cexpr! l:result		" jump
    endif
    let &efm = l:efm_org
endfunction

"
" RunGlobal()
"
function! s:RunGlobal(line, flags)
    let l:pattern = s:Extract(a:line, 'pattern')

    if l:pattern == '%'
        let l:pattern = expand('%')
    elseif l:pattern == '#'
        let l:pattern = expand('#')
    endif
    let l:option = s:Extract(a:line, 'option')
    " If no pattern supplied then get it from user.
    if l:pattern == ''
        let s:option = l:option
        if l:option =~# 'f'
            let l:line = input("Gtags for file: ", expand('%'), 'file')
        else
            let l:line = input("Gtags for pattern: ", expand('<cword>'), 'custom,GtagsCandidateCore')
        endif
        let l:pattern = s:Extract(l:line, 'pattern')
        if l:pattern == ''
            call s:Error('Pattern not specified.')
            return
        endif
    endif
    call s:ExecLoad(l:option, '', l:pattern, a:flags)
endfunction

"
" Execute RunGlobal() depending on the current position.
"
function! s:GtagsCursor()
    let l:pattern = expand("<cword>")
    let l:option = "--from-here=\"" . line('.') . ":" . expand("%") . "\""
    call s:ExecLoad('', l:option, l:pattern, '')
endfunction

"
" Show the current position on mozilla.
" (You need to execute htags(1) in your source directory.)
"
function! s:Gozilla()
    let l:lineno = line('.')
    let l:filename = expand("%")
    let l:result = system('gozilla +' . l:lineno . ' ' . l:filename)
endfunction
"
" Auto update of tag files using incremental update facility.
"
function! s:GtagsAutoUpdate()
    let l:result = system(s:global_command . " -u --single-update=\"" . expand("%") . "\"")
endfunction

"
" Custom completion.
"
function! GtagsCandidate(lead, line, pos)
    let s:option = s:Extract(a:line, 'option')
    return GtagsCandidateCore(a:lead, a:line, a:pos)
endfunction

function! GtagsCandidateCore(lead, line, pos)
    if s:option ==# 'g'
        return ''
    elseif s:option ==# 'f'
        if isdirectory(a:lead)
            if a:lead =~ '/$'
                let l:pattern = a:lead . '*'
            else
                let l:pattern = a:lead . '/*'
            endif
        else
            let l:pattern = a:lead . '*'
        endif
        return glob(l:pattern)
    else 
        return system(s:global_command . ' ' . '-c' . s:option . ' ' . a:lead)
    endif
endfunction

" Define the set of Gtags commands
command! -nargs=* -complete=custom,GtagsCandidate Gtags call s:RunGlobal(<q-args>, '')
command! -nargs=* -complete=custom,GtagsCandidate Gtagsa call s:RunGlobal(<q-args>, 'a')
command! -nargs=0 GtagsCursor call s:GtagsCursor()
command! -nargs=0 Gozilla call s:Gozilla()
command! -nargs=0 GtagsUpdate call s:GtagsAutoUpdate()
if g:Gtags_Auto_Update == 1
	:autocmd! BufWritePost * call s:GtagsAutoUpdate()
endif
" Suggested map:
if g:Gtags_Auto_Map == 1
	:nmap <F2> :copen<CR>
	:nmap <F4> :cclose<CR>
	:nmap <F5> :Gtags<SPACE>
	:nmap <F6> :Gtags -f %<CR>
	:nmap <F7> :GtagsCursor<CR>
	:nmap <F8> :Gozilla<CR>
	:nmap <C-n> :cn<CR>
	:nmap <C-p> :cp<CR>
	:nmap <C-\><C-]> :GtagsCursor<CR>
endif
let loaded_gtags = 1
