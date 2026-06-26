local M = {}

-- Source: https://github.com/yioneko/vtsls/blob/main/packages/service/configuration.schema.json
-- NOTE: Don't change settings here
M.settings = {
  both = {
    referencesCodeLens = {
      -- Enable/disable references CodeLens in TypeScript files.
      -- Default: false
      enabled = false, ---@type boolean
      -- Enable/disable references CodeLens on all functions in TypeScript files.
      -- Default: false
      showOnAllFunctions = false, ---@type boolean
    },
    validate = {
      -- Enable/disable TypeScript validation.
      -- Default: true
      enable = true, ---@type boolean
    },
    suggestionActions = {
      -- Enable/disable suggestion diagnostics for JavaScript files in the editor.
      -- Default: true
      enabled = true, ---@type boolean
    },
    updateImportsOnFileMove = {
      -- Enable/disable automatic updating of import paths when you rename or move a file in VS Code.
      -- Default: prompt
      enabled = "prompt", ---@type "prompt"|"always"|"never"
    },
    -- Makes `Go to Definition` avoid type declaration files when possible by triggering `Go to Source Definition` instead. This allows `Go to Source Definition` to be triggered with the mouse gesture.
    -- Default: false
    preferGoToSourceDefinition = false, ---@type boolean
    suggest = {
      -- Enable/disable autocomplete suggestions.
      -- Default: true
      enabled = true, ---@type boolean
      -- Enable/disable auto import suggestions.
      -- Default: true
      autoImports = true, ---@type boolean
      -- Complete functions with their parameter signature.
      -- Default: false
      completeFunctionCalls = false, ---@type boolean
      -- Enable/disable suggestions for paths in import statements and require calls.
      -- Default: true
      paths = true, ---@type boolean
      -- Enable/disable suggestion to complete JSDoc comments.
      -- Default: true
      completeJSDocs = true, ---@type boolean
      jsdoc = {
        -- Enable/disable generating `@returns` annotations for JSDoc templates.
        -- Default: true
        generateReturns = true, ---@type boolean
      },
      -- Enable/disable showing completions on potentially undefined values that insert an optional chain call. Requires strict null checks to be enabled.
      -- Default: true
      includeAutomaticOptionalChainCompletions = true, ---@type boolean
      -- Enable/disable auto-import-style completions on partially-typed import statements.
      -- Default: true
      includeCompletionsForImportStatements = true, ---@type boolean
      classMemberSnippets = {
        -- Enable/disable snippet completions for class members.
        -- Default: true
        enabled = true, ---@type boolean
      },
    },
    preferences = {
      -- Preferred quote style to use for Quick Fixes.
      -- Default: auto
      quoteStyle = "auto", ---@type "auto"|"single"|"double"
      -- Preferred path style for auto imports.
      -- Default: shortest
      importModuleSpecifier = "shortest", ---@type "shortest"|"relative"|"non-relative"|"project-relative"
      -- Preferred path ending for auto imports.
      -- Default: auto
      importModuleSpecifierEnding = "auto", ---@type "auto"|"minimal"|"index"|"js"
      -- Preferred style for JSX attribute completions.
      -- Default: auto
      jsxAttributeCompletionStyle = "auto", ---@type "auto"|"braces"|"none"
      -- Specify glob patterns of files to exclude from auto imports. Relative paths are resolved relative to the workspace root. Patterns are evaluated using tsconfig.json [`exclude`](https://www.typescriptlang.org/tsconfig#exclude) semantics.
      autoImportFileExcludePatterns = {}, ---@type table
      -- Specify regular expressions to exclude auto imports with matching import specifiers. Examples:
      --
      -- - `^node:`
      -- - `lib/internal` (slashes don't need to be escaped...)
      -- - `/lib\/internal/i` (...unless including surrounding slashes for `i` or `u` flags)
      -- - `^lodash$` (only allow subpath imports from lodash)
      -- Default: {}
      autoImportSpecifierExcludeRegexes = {}, ---@type table
      -- Enable/disable introducing aliases for object shorthand properties during renames.
      -- Default: true
      useAliasesForRenames = true, ---@type boolean
      -- When on a JSX tag, try to rename the matching tag instead of renaming the symbol. Requires using TypeScript 5.1+ in the workspace.
      -- Default: true
      renameMatchingJsxTags = true, ---@type boolean
      -- Advanced preferences that control how imports are ordered.
      -- Default: {}
      organizeImports = {}, ---@type table
    },
    format = {
      -- Enable/disable default JavaScript formatter.
      -- Default: true
      enable = true, ---@type boolean
      -- Defines space handling after a comma delimiter.
      -- Default: true
      insertSpaceAfterCommaDelimiter = true, ---@type boolean
      -- Defines space handling after the constructor keyword.
      -- Default: false
      insertSpaceAfterConstructor = false, ---@type boolean
      -- Defines space handling after a semicolon in a for statement.
      -- Default: true
      insertSpaceAfterSemicolonInForStatements = true, ---@type boolean
      -- Defines space handling after a binary operator.
      -- Default: true
      insertSpaceBeforeAndAfterBinaryOperators = true, ---@type boolean
      -- Defines space handling after keywords in a control flow statement.
      -- Default: true
      insertSpaceAfterKeywordsInControlFlowStatements = true, ---@type boolean
      -- Defines space handling after function keyword for anonymous functions.
      -- Default: true
      insertSpaceAfterFunctionKeywordForAnonymousFunctions = true, ---@type boolean
      -- Defines space handling before function argument parentheses.
      -- Default: false
      insertSpaceBeforeFunctionParenthesis = false, ---@type boolean
      -- Defines space handling after opening and before closing non-empty parenthesis.
      -- Default: false
      insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false, ---@type boolean
      -- Defines space handling after opening and before closing non-empty brackets.
      -- Default: false
      insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false, ---@type boolean
      -- Defines space handling after opening and before closing non-empty braces.
      -- Default: true
      insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true, ---@type boolean
      -- Defines space handling after opening and before closing empty braces.
      -- Default: true
      insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true, ---@type boolean
      -- Defines space handling after opening and before closing template string braces.
      -- Default: false
      insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false, ---@type boolean
      -- Defines space handling after opening and before closing JSX expression braces.
      -- Default: false
      insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false, ---@type boolean
      -- Defines whether an open brace is put onto a new line for functions or not.
      -- Default: false
      placeOpenBraceOnNewLineForFunctions = false, ---@type boolean
      -- Defines whether an open brace is put onto a new line for control blocks or not.
      -- Default: false
      placeOpenBraceOnNewLineForControlBlocks = false, ---@type boolean
      -- Defines handling of optional semicolons.
      -- Default: ignore
      semicolons = "ignore", ---@type "ignore"|"insert"|"remove"
      -- Indent case clauses in switch statements. Requires using TypeScript 5.1+ in the workspace.
      -- Default: true
      indentSwitchCase = true, ---@type boolean
    },
    inlayHints = {
      parameterNames = {
        -- Enable/disable inlay hints for parameter names:
        -- ```typescript
        --
        -- parseInt(/* str: */ '123', /* radix: */ 8)
        --
        -- ```
        -- Default: none
        enabled = "none", ---@type "none"|"literals"|"all"
        -- Suppress parameter name hints on arguments whose text is identical to the parameter name.
        -- Default: true
        suppressWhenArgumentMatchesName = true, ---@type boolean
      },
      parameterTypes = {
        -- Enable/disable inlay hints for implicit parameter types:
        -- ```typescript
        --
        -- el.addEventListener('click', e /* :MouseEvent */ => ...)
        --
        -- ```
        -- Default: false
        enabled = false, ---@type boolean
      },
      variableTypes = {
        -- Enable/disable inlay hints for implicit variable types:
        -- ```typescript
        --
        -- const foo /* :number */ = Date.now();
        --
        -- ```
        -- Default: false
        enabled = false, ---@type boolean
        -- Suppress type hints on variables whose name is identical to the type name.
        -- Default: true
        suppressWhenTypeMatchesName = true, ---@type boolean
      },
      propertyDeclarationTypes = {
        -- Enable/disable inlay hints for implicit types on property declarations:
        -- ```typescript
        --
        -- class Foo {
        -- 	prop /* :number */ = Date.now();
        -- }
        --
        -- ```
        -- Default: false
        enabled = false, ---@type boolean
      },
      functionLikeReturnTypes = {
        -- Enable/disable inlay hints for implicit return types on function signatures:
        -- ```typescript
        --
        -- function foo() /* :number */ {
        -- 	return Date.now();
        -- }
        --
        -- ```
        -- Default: false
        enabled = false, ---@type boolean
      },
    },
  },
  javascript = {
    suggest = {
      -- Enable/disable including unique names from the file in JavaScript suggestions. Note that name suggestions are always disabled in JavaScript code that is semantically checked using `@ts-check` or `checkJs`.
      -- Default: true
      names = true, ---@type boolean
    },
  },
  typescript = {
    -- Specifies the folder path to the tsserver and `lib*.d.ts` files under a TypeScript install to use for IntelliSense, for example: `./node_modules/typescript/lib`.
    --
    -- - When specified as a user setting, the TypeScript version from `typescript.tsdk` automatically replaces the built-in TypeScript version.
    -- - When specified as a workspace setting, `typescript.tsdk` allows you to switch to use that workspace version of TypeScript for IntelliSense with the `TypeScript: Select TypeScript version` command.
    --
    -- See the [TypeScript documentation](https://code.visualstudio.com/docs/typescript/typescript-compiling#_using-newer-typescript-versions) for more detail about managing TypeScript versions.
    -- Default: nil
    tsdk = nil, ---@type string?
    -- Disables [automatic type acquisition](https://code.visualstudio.com/docs/nodejs/working-with-javascript#_typings-and-automatic-type-acquisition). Automatic type acquisition fetches `@types` packages from npm to improve IntelliSense for external libraries.
    -- Default: false
    disableAutomaticTypeAcquisition = false, ---@type boolean
    implementationsCodeLens = {
      -- Enable/disable implementations CodeLens. This CodeLens shows the implementers of an interface.
      -- Default: false
      enabled = false, ---@type boolean
      -- Enable/disable implementations CodeLens on interface methods.
      -- Default: false
      showOnInterfaceMethods = false, ---@type boolean
      -- Enable/disable showing implementations CodeLens above all class methods instead of only on abstract methods.
      -- Default: false
      showOnAllClassMethods = false, ---@type boolean
    },
    -- Report style checks as warnings.
    -- Default: true
    reportStyleChecksAsWarnings = true, ---@type boolean
    -- Sets the locale used to report JavaScript and TypeScript errors. Defaults to use VS Code's locale.
    -- Default: auto
    locale = "auto", ---@type "auto"|"de"|"es"|"en"|"fr"|"it"|"ja"|"ko"|"ru"|"zh-CN"|"zh-TW"
    workspaceSymbols = {
      -- Controls which files are searched by [Go to Symbol in Workspace](https://code.visualstudio.com/docs/editor/editingevolved#_open-symbol-by-name).
      -- Default: allOpenProjects
      scope = "allOpenProjects", ---@type "allOpenProjects"|"currentProject"
      -- Exclude symbols that come from library files in `Go to Symbol in Workspace` results. Requires using TypeScript 5.3+ in the workspace.
      -- Default: true
      excludeLibrarySymbols = true, ---@type boolean
    },
    suggest = {
      objectLiteralMethodSnippets = {
        -- Enable/disable snippet completions for methods in object literals.
        -- Default: true
        enabled = true, ---@type boolean
      },
    },
    preferences = {
      -- Enable/disable searching `package.json` dependencies for available auto imports.
      -- Default: auto
      includePackageJsonAutoImports = "auto", ---@type "auto"|"on"|"off"
      -- Include the `type` keyword in auto-imports whenever possible. Requires using TypeScript 5.3+ in the workspace.
      -- Default: false
      preferTypeOnlyAutoImports = false, ---@type boolean
    },
    format = {
      -- Defines space handling after type assertions in TypeScript.
      -- Default: false
      insertSpaceAfterTypeAssertion = false, ---@type boolean
    },
    inlayHints = {
      enumMemberValues = {
        -- Enable/disable inlay hints for member values in enum declarations:
        -- ```typescript
        --
        -- enum MyValue {
        -- 	A /* = 0 */;
        -- 	B /* = 1 */;
        -- }
        --
        -- ```
        -- Default: false
        enabled = false, ---@type boolean
      },
    },
    tsserver = {
      -- Run TS Server on a custom Node installation. This can be a path to a Node executable, or 'node' if you want VS Code to detect a Node installation.
      -- Default: nil
      nodePath = nil, ---@type string?
      web = {
        projectWideIntellisense = {
          -- Enable/disable project-wide IntelliSense on web. Requires that VS Code is running in a trusted context.
          -- Default: true
          enabled = true, ---@type boolean
          -- Suppresses semantic errors on web even when project wide IntelliSense is enabled. This is always on when project wide IntelliSense is not enabled or available. See `#typescript.tsserver.web.projectWideIntellisense.enabled#`
          -- Default: false
          suppressSemanticErrors = false, ---@type boolean
        },
        typeAcquisition = {
          -- Enable/disable package acquisition on the web. This enables IntelliSense for imported packages. Requires `#typescript.tsserver.web.projectWideIntellisense.enabled#`. Currently not supported for Safari.
          -- Default: true
          enabled = true, ---@type boolean
        },
      },
      -- Controls if TypeScript launches a dedicated server to more quickly handle syntax related operations, such as computing code folding.
      -- Default: auto
      useSyntaxServer = "auto", ---@type "always"|"never"|"auto"
      -- The maximum amount of memory (in MB) to allocate to the TypeScript server process. To use a memory limit greater than 4 GB, use `#typescript.tsserver.nodePath#` to run TS Server with a custom Node installation.
      -- Default: 3072
      maxTsServerMemory = 3072, ---@type number
      experimental = {
        -- Enables project wide error reporting.
        -- Default: false
        enableProjectDiagnostics = false, ---@type boolean
      },
      -- Configure which watching strategies should be used to keep track of files and directories.
      watchOptions = {
        -- Strategy for how individual files are watched.
        -- "fixedChunkSizePolling":        "Polls files in chunks at regular interval.",
        -- "fixedPollingInterval":         "Check every file for changes several times a second at a fixed interval.",
        -- "priorityPollingInterval":      "Check every file for changes several times a second, but use heuristics to check certain types of files less frequently than others.",
        -- "dynamicPriorityPolling":       "Use a dynamic queue where less-frequently modified files will be checked less often.",
        -- "useFsEvents":                  "Attempt to use the operating system/file system's native events for file changes.",
        -- "useFsEventsOnParentDirectory": "Attempt to use the operating system/file system's native events to listen for changes on a file's containing directories. This can use fewer file watchers, but might be less accurate."
        -- Default: nil
        watchFile = nil, ---@type "fixedChunkSizePolling"|"fixedPollingInterval"|"priorityPollingInterval"|"dynamicPriorityPolling"|"useFsEvents"|"useFsEventsOnParentDirectory"
        -- Strategy for how entire directory trees are watched under systems that lack recursive file-watching functionality.
        -- "fixedChunkSizePolling":  "Polls directories in chunks at regular interval.",
        -- "fixedPollingInterval":   "Check every directory for changes several times a second at a fixed interval.",
        -- "dynamicPriorityPolling": "Use a dynamic queue where less-frequently modified directories will be checked less often.",
        -- "useFsEvents":            "Attempt to use the operating system/file system's native events for directory changes."
        -- Default: nil
        watchDirectory = nil, ---@type "fixedChunkSizePolling"|"fixedPollingInterval"|"dynamicPriorityPolling"|"useFsEvents"
        -- When using file system events, this option specifies the polling strategy that gets used when the system runs out of native file watchers and/or doesn't support native file watchers.
        -- "fixedPollingInterval":    "Check every file for changes several times a second at a fixed interval."
        -- "priorityPollingInterval": "Check every file for changes several times a second, but use heuristics to check certain types of files less frequently than others."
        -- "dynamicPriorityPolling":  "Use a dynamic queue where less-frequently modified directories will be checked less often.
        -- Default: nil
        fallbackPolling = nil, ---@type "fixedPollingInterval"|"priorityPollingInterval"|"dynamicPriorityPolling"
        -- Disable deferred watching on directories. Deferred watching is useful when lots of file changes might occur at once (e.g. a change in node_modules from running npm install), but you might want to disable it with this flag for some less-common setups.
        -- Default: nil
        synchronousWatchDirectory = nil, ---@type boolean
      },
      -- Enables tracing TS server performance to a directory. These trace files can be used to diagnose TS Server performance issues. The log may contain file paths, source code, and other potentially sensitive information from your project.
      -- Default: false
      enableTracing = false, ---@type boolean
      -- Enables logging of the TS server to a file. This log can be used to diagnose TS Server issues. The log may contain file paths, source code, and other potentially sensitive information from your project.
      -- Default: off
      log = "off", ---@type "off"|"terse"|"normal"|"verbose"|"requestTime"
      -- Additional paths to discover TypeScript Language Service plugins.
      -- Default: {}
      pluginPaths = {}, ---@type table
    },
    -- Specifies the path to the npm executable used for [Automatic Type Acquisition](https://code.visualstudio.com/docs/nodejs/working-with-javascript#_typings-and-automatic-type-acquisition).
    -- Default: nil
    npm = nil, ---@type string?
    check = {
      -- Check if npm is installed for [Automatic Type Acquisition](https://code.visualstudio.com/docs/nodejs/working-with-javascript#_typings-and-automatic-type-acquisition).
      -- Default: true
      npmIsInstalled = true, ---@type boolean
    },
  },
  ["js/ts"] = {
    implicitProjectConfig = {
      -- Sets the module system for the program. See more: https://www.typescriptlang.org/tsconfig#module.
      -- Default: ESNext
      module = "ESNext", ---@type "CommonJS"|"AMD"|"System"|"UMD"|"ES6"|"ES2015"|"ES2020"|"ESNext"|"None"|"ES2022"|"Node12"|"NodeNext"
      -- Set target JavaScript language version for emitted JavaScript and include library declarations. See more: https://www.typescriptlang.org/tsconfig#target.
      -- Default: ES2024
      target = "ES2024", ---@type "ES3"|"ES5"|"ES6"|"ES2015"|"ES2016"|"ES2017"|"ES2018"|"ES2019"|"ES2020"|"ES2021"|"ES2022"|"ES2023"|"ES2024"|"ESNext"
      -- Enable/disable semantic checking of JavaScript files. Existing `jsconfig.json` or `tsconfig.json` files override this setting.
      -- Default: false
      checkJs = false, ---@type boolean
      -- Enable/disable `experimentalDecorators` in JavaScript files that are not part of a project. Existing `jsconfig.json` or `tsconfig.json` files override this setting.
      -- Default: false
      experimentalDecorators = false, ---@type boolean
      -- Enable/disable [strict null checks](https://www.typescriptlang.org/tsconfig#strictNullChecks) in JavaScript and TypeScript files that are not part of a project. Existing `jsconfig.json` or `tsconfig.json` files override this setting.
      -- Default: true
      strictNullChecks = true, ---@type boolean
      -- Enable/disable [strict function types](https://www.typescriptlang.org/tsconfig#strictFunctionTypes) in JavaScript and TypeScript files that are not part of a project. Existing `jsconfig.json` or `tsconfig.json` files override this setting.
      -- Default: true
      strictFunctionTypes = true, ---@type boolean
      -- Enable/disable [strict mode](https://www.typescriptlang.org/tsconfig#strict) in JavaScript and TypeScript files that are not part of a project. Existing `jsconfig.json` or `tsconfig.json` files override this setting.
      -- Default: true
      strict = true, ---@type boolean
    },
    hover = {
      -- The maximum number of characters in a hover. If the hover is longer than this, it will be truncated. Requires TypeScript 5.9+.
      -- Default: 500
      maximumLength = 500, ---@type number
    },
  },
  vtsls = {
    typescript = {
      -- Default: nil
      globalTsdk = nil, ---@type string?
    },
    experimental = {
      completion = {
        -- Execute fuzzy match of completion items on server side. Enable this will help filter out useless completion items from tsserver.
        -- Default: false
        enableServerSideFuzzyMatch = false, ---@type boolean
        -- Maximum number of completion entries to return. Recommend to also toggle `enableServerSideFuzzyMatch` to preserve items with higher accuracy.
        -- Default: nil
        entriesLimit = nil, ---@type number?
      },
      -- Maximum length of single inlay hint. Note that hint is simply truncated if the limit is exceeded. Do not set this if your client already handles overly long hints gracefully.
      -- Default: nil
      maxInlayHintLength = nil, ---@type number?
    },
    -- Enable 'Move to file' code action. This action enables user to move code to existing file, but requires corresponding handling on the client side.
    -- Default: false
    enableMoveToFileCodeAction = false, ---@type boolean
    -- Automatically use workspace version of TypeScript lib on startup. By default, the bundled version is used for intelliSense.
    -- Default: false
    autoUseWorkspaceTsdk = false, ---@type boolean
    tsserver = {
      -- TypeScript plugins that are not locally avaiable in the workspace. Usually the plugin configuration can be found in the `contributes.typescriptServerPlugins` field of `package.json` of the corresponding VSCode extension.
      -- Default: {}
      globalPlugins = {}, ---@type table
    },
  },
}

M.on_save = tie(
  "LSP vtsls -> Do things on save",
  ---@param client vim.lsp.Client
  function(client)
    tied.create_autocmd({
      desc = "Fix imports on save",
      event = "User",
      pattern = "BeforeConformFormat",
      group = tied.create_augroup("my.lsp.vtsls.on_save", true),
      callback = function(ev)
        if not client.attached_buffers[ev.buf] then
          return
        end

        local bufnr = ev.buf
        local ft = vim.bo[bufnr].filetype

        tied.run_lsp_codeaction({
          client_id = client.id,
          kind = "source.addMissingImports.ts",
          bufnr = bufnr,
        })

        local file_path = vim.api.nvim_buf_get_name(bufnr)
        local cmd_names = {
          "typescript.removeUnusedImports",
          "javascript.removeUnusedImports",
          "typescript.sortImports",
          "javascript.sortImports",
          "typescript.organizeImports",
        }

        tied.for_list(
          "Run LSP vtsls command before file format",
          cmd_names,
          function(_, cmd_name)
            if ft:sub(0, 10) ~= cmd_name:sub(0, 10) then
              return
            end

            tied.run_lsp_command({
              client = client,
              bufnr = bufnr,
              cmd = {
                title = cmd_name,
                command = cmd_name,
                arguments = { file_path },
              },
            })
          end
        )
      end,
    })
  end,
  tied.do_nothing
)

return M
