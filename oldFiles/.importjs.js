module.exports = {
    // aliases: {
    //     $: 'third-party-libs/jquery',
    //     _: 'third-party-libs/underscore',
    // },
    // ignorePackagePrefixes: ['my-company-'],
    // mergableOptions: {
    //     aliases: true,
    //     coreModules: true,
    //     namedExports: true,
    //     globals: true,
    // }
    // importFunction: 'require',
    // environments: ['browser', 'node'],
    logLevel: 'debug',
    excludes: ['./e2e/node_modules/**', './*.js', './mockData/**', './routes/**', './coverage/**', './tests/**', './build-assets/**'],
    emptyLineBetweenGroups: false,
    sortImports: true,
    groupImports: true,
    importDevDependencies: true,
    danglingCommas: false,
    stripFileExtensions: ['.jsx', '.js'],
    maxLineLength: 120,
    tab: '    ',
    mergableOptions: { globals: false },
    globals: [ 'module', 'expect' ],
    namedExports: {
        'prop-types': [ 'bool', 'number', 'string', 'object', 'array', 'func', 'element', 'any', 'oneOfType', 'oneOf', 'arrayOf', 'objectOf', 'shape' ],
        'react-immutable-proptypes': [ 'list', 'map' ],
        'immutable': [ 'fromJS', 'Map', 'List', 'OrderedMap', 'OrderedSet', 'Set', 'is', 'isImmutable' ],
        'reselect': [ 'createSelector' ],
        'redux-saga/effects': [ 'all', 'join', 'put', 'call', 'select', 'take', 'race', 'takeLatest', 'takeEvery', 'fork', 'cancel', 'spawn' ],
        'redux-saga': [ 'delay' ],
        'react-redux': [ 'connect' ],
        'redux': [ 'bindActionCreators' ]
    },
    useRelativePaths({ pathToImportedModule, pathToCurrentFile }) {
        // if (pathToCurrentFile.includes('app') || pathToCurrentFile.includes('e2e')) {
            return false
        // }

        // return true
    },
    declarationKeyword({ pathToImportedModule, pathToCurrentFile }) {
        // if (pathToCurrentFile.includes('app')) {
            return 'import'
        // }

        // return 'const'
    },
    moduleNameFormatter({ moduleName, pathToCurrentFile, pathToImportedModule }) {
        if (moduleName.startsWith('app/js/')) {
            return moduleName.replace('app/js/', '')
        }

        if (moduleName.startsWith('e2e/')) {
            return moduleName.replace('e2e/', '')
        }

        return moduleName
    },
    importStatementFormatter({ importStatement }) {
        return importStatement.replace(/;$/, '');
    }
}
