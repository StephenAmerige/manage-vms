# Third-party software notices

The root [`LICENSE`](LICENSE) applies to the **original project code and
original documentation** provided by Stephen Amerige. It **does not relicense**
third-party components bundled in `files/vim/runtime/`. The files listed below
retain their own copyright statements, permissions, and restrictions. Keep the
original notices in their source files when redistributing them.

This inventory is based on notices in the distributed files and published
upstream materials. It does not assert that every historical component has a
verified license or that all permissions have been independently established.

| Component | Included files | Copyright/credit | License evidence and terms |
| --- | --- | --- | --- |
| **ZoomWin** | `files/vim/runtime/vimfiles/autoload/ZoomWin.vim`, `plugin/ZoomWinPlugin.vim`, `doc/ZoomWin.txt` | Charles E. Campbell, Jr.; original work by Ron Aaron | **Vim License**, explicitly stated in `doc/ZoomWin.txt`; full text in [`licenses/Vim.txt`](licenses/Vim.txt) |
| **BufExplorer** | `files/vim/runtime/vimfiles/plugin/bufexplorer.vim`, `doc/bufexplorer.txt` | Copyright (c) 2001–2014 Jeff Lanzarotta | **BSD-style three-clause terms**, including warranty disclaimer, reproduced in the beginning of `plugin/bufexplorer.vim` |
| **DirDiff** | `files/vim/runtime/vimfiles/plugin/dirdiff.vim`, `doc/dirdiff.txt` | Copyright (c) 2001–2015 William Lee | **BSD-like terms** including conditions and disclaimer, preserved in `doc/dirdiff.txt` under `dirdiff-license` |
| **ShowMarks** | `files/vim/runtime/vimfiles/plugin/showmarks.vim`, `doc/showmarks.txt` | Anthony Kruize and Michael Geddes | Plugin header states **released into the public domain** |
| **SaveVers** | `files/vim/runtime/vimfiles/plugin/savevers.vim` | Copyright (c) 2001 Ed Ralston | Header permits distribution, use, and modification under **GNU GPL version 2** (no later-version option stated); full license in [`licenses/GPL-2.0.txt`](licenses/GPL-2.0.txt) |
| **JSON Vim syntax** | `files/vim/runtime/vimfiles/syntax/json.vim` | Copyright (c) 2013 Jeroen Ruigrok van der Werven and Eli Parra | **MIT**; source includes its own copyright and full MIT notice |
| **Ya2YAML** | `files/vim/runtime/vimfiles/lib/ya2yaml.rb` | Copyright (c) 2006 Akira Funai | Header identifies **MIT License** |
| **YAMLator** | `files/vim/runtime/vimfiles/lib/yamlator.rb` | Henrik Nyh (2010) | Header identifies **MIT License** |
| **Summerfruit256** | `files/vim/runtime/vimfiles/colors/summerfruit256.vim` | Martin Baeuml; derived from Armin Ronacher's `summerfruit` scheme; Henry So's color approximation | **Redistribution license not verified. See unresolved item below.** |

## License texts and preserved source notices

- [`licenses/GPL-2.0.txt`](licenses/GPL-2.0.txt): verbatim GPL version 2
  license text included for SaveVers. The GPL applies to the plugin as stated
  in its header; MIT licensing of independent provisioning scripts does not
  erase the GPL obligations when distributing that plugin.
- [`licenses/Vim.txt`](licenses/Vim.txt): verbatim Vim License text included
  for ZoomWin, as referenced in the bundled help file.
- BufExplorer and DirDiff source/documentation files already include their
  full BSD-style redistribution terms and disclaimers; do not strip them.
- JSON syntax includes its MIT license notice in its source. Ya2YAML and
  YAMLator identify MIT in their headers. The standard MIT license terms are
  also reproduced in the root `LICENSE`, with this file preserving attribution
  to the other authors.

## Unresolved: Summerfruit256 redistribution rights

The bundled `summerfruit256.vim` credits Martin Baeuml, Armin Ronacher,
and Henry So, but does not state a license. The upstream Vim-script mirror
([`vim-scripts/summerfruit256.vim`](https://github.com/vim-scripts/summerfruit256.vim))
also does not supply a license file. **Public availability is not proof of
permission to redistribute.** Before presenting the full bundle as fully
cleared for third-party redistribution, obtain a license or permission from
its copyright holders, or replace the colorscheme with a clearly licensed
alternative and update `.vimrc` accordingly. That decision is deliberately
*not* made by this licensing-only change, which leaves functioning Vim
configuration untouched.

## Remaining provenance check

The `files/vim/runtime/template/` scripts and the repository's historical
shell/editor configuration should be reviewed for any additional borrowed
materials before asserting that every file is solely original. Original
project-authored files are intended to be MIT-licensed; third-party portions
remain subject to their own terms even when not itemized here.

**This notice is informational, not an assertion of additional rights or a
replacement for the individual third-party licenses.**
