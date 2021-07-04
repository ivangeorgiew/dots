const ErrorHandlingUtils = class Self {
    static stringifyAll(data) {
        try {
            const parser = function(_key, val) {
                if (val instanceof Error) {
                    return Object.getOwnPropertyNames(val).reduce((acc, key) => {
                        acc[key] = val[key]
                        return acc
                    }, { stack: val.stack })
                }

                if (typeof val === 'function') {
                    if (/^\s*async\s+/g.test(val)) {
                         return '[function Async]'
                    }

                    if (/^\s*class\s*\w*/g.test(val)) {
                        return '[function Class]'
                    }

                    if (/^\s*function\s*\*/g.test(val)) {
                        return '[function Generator]'
                    }

                    if (/^\s*\(.*\)\s+=>/g.test(val)) {
                        return '[function Arrow]'
                    }

                    return '[function Function]'
                }

                return val
            }

            return JSON.stringify(data, parser)
        } catch(e) {
            return JSON.stringify('[object Cyclic]')
        }
    }

    static logError(params) {
        params = params === Object(params) ? params : {}

        const funcDesc = typeof params.funcDesc === 'string' ?
            params.funcDesc :
            'Unknown function'
        const err = params.err instanceof Error ?
            params.err :
            new Error('Unknown error')
        const args = Array.isArray(params.args) ?
            params.args.map(el => JSON.parse(Self.stringifyAll(el))) :
            ['[unknown]']

        const stringOfArgs = args.reduce((acc, arg, idx) => {
            return idx === 0 ? (acc + arg) : (acc + ` , ${arg}`)
        }, '')

        //TODO log in development
        console.log()
        console.error(` Issue with: ${funcDesc}\n Function arguments: ${stringOfArgs}\n`, err)
        console.log()

        const commonProps = {
            functionDescription: funcDesc,
            arguments: args,
            date: new Date().toUTCString(),
            error: err
        }

        if (Self.isBrowser) {
            //TODO notify the user
            alert(`Internal error with: ${funcDesc}`)

            //TODO logging service in production
            console.info(Self.stringifyAll({
                ...commonProps,
                localUrl: window.location.href,
                machineInfo: {
                    browserInfo: window.navigator.userAgent,
                    language: window.navigator.language,
                    osType: window.navigator.platform
                }
            }))
        }

        if (Self.isNodeJS) {
            //TODO logging service in production
            console.info(Self.stringifyAll({
                ...commonProps,
                localUrl: __filename,
                machineInfo: {
                    cpuArch: process.arch,
                    osType: process.platform,
                    depVersions: process.versions
                }
            }))
        }
    }

    static createFunc(funcDesc, onTry, onCatch) {
        if (typeof onTry !== 'function') {
            Self.logError({
                funcDesc: 'Undefined function',
                err: new Error(`Instead of function was given ${onTry}`)
            })

            return function() {}
        }

        const innerCatch = function({ err, args }) {
            Self.logError({ funcDesc, err, args })

            if (typeof onCatch === 'function') {
                return Self.createFunc('Catching errors', onCatch)
                    .apply(this, args)
            }
        }

        if (onTry.constructor.name === 'AsyncFunction') {
            return async function (...args) {
                try {
                    return await onTry.apply(this, args)
                } catch(err) {
                    return innerCatch.call(this, { err, args })
                }
            }
        }

        return function (...args) {
            try {
                return onTry.apply(this, args)
            } catch(err) {
                return innerCatch.call(this, { err, args })
            }
        }
    }
}

const ClassUtils = class Self {
    static deepFreeze(obj) {
        Object.getOwnPropertyNames(obj).forEach(key => {
            if (
                key !== 'prototype' &&
                typeof obj[key] === 'object' &&
                obj[key] !== null
            ) {
                Self.deepFreeze(obj[key])
            }
        })

        Object.freeze(obj)
    }

    static inheritUniqueProps(obj, source) {
        Object.getOwnPropertyNames(source).forEach(key => {
            if (!obj.hasOwnProperty(key)) {
                obj[key] = source[key]
            }
        })
    }

    static errorHandleMethods(obj, shouldHandleProto = true) {
        Object.getOwnPropertyNames(obj).forEach(key => {
            if (key !== 'constructor' && obj[key] instanceof Function) {
                obj[key] = ErrorHandlingUtils.createFunc
                    .call(obj, `Executing method ${key}`, obj[key], obj.onCatch)
            }
        })

        if(shouldHandleProto) {
            Self.errorHandleMethods(obj.prototype, false)
        }
    }

    static setClassProps(classObj, { name, props = {}, inherited = [] } = {}) {
        if (typeof name === 'string') {
            Object.defineProperty(classObj, 'name', {
                value: name,
                configurable: true,
                enumerable: false,
                writable: false
            })
        }

        // set class props
        Object.assign(classObj, props)

        // inherit props from other classes
        inherited.forEach(constr => {
            // class inherits static props
            Self.inheritUniqueProps(classObj, constr)
            // class inherits prototype props
            Self.inheritUniqueProps(classObj.prototype, constr.prototype)
        })
    }
}

// finalize ErrorHandlingUtils
ClassUtils.setClassProps(ErrorHandlingUtils, {
    name: 'ErrorHandlingUtils',
    props: {
        isBrowser: typeof window !== 'undefined' &&
            ({}).toString.call(window) === '[object Window]',
        isNodeJS: typeof global !== "undefined" &&
            ({}).toString.call(global) === '[object global]'
    }
})
ClassUtils.deepFreeze(ErrorHandlingUtils)

// finalize ClassUtils
ClassUtils.setClassProps(ClassUtils, { name: 'ClassUtils' })
ClassUtils.errorHandleMethods(ClassUtils)
ClassUtils.deepFreeze(ClassUtils)



// we use this class with "class Self extends PureClass"
// hence we want only the completely necessary methods
const PureClass = class Self {
    constructor(...args) {
        //get the props from other classes
        const classesToInherit = this.constructor.inherited || []

        //assign the enumerable props
        classesToInherit.forEach(constr => {
            Object.assign(this, new constr(...args))
        })

        //bind the methods per object
        const targetProto = Object.getPrototypeOf(this)

        Object.getOwnPropertyNames(targetProto).forEach(key => {
            if (key !== 'constructor' && targetProto[key] instanceof Function) {
                this[key] = targetProto[key].bind(this)
            }
        })

        // give access to all the arguments
        this.args = args
    }

    static finalizeClass({ name, props = {}, inherited = [] } = {}) {
        // give access to the inherited classes
        this.inherited = inherited

        ClassUtils.setClassProps(this, { name, props, inherited })
        ClassUtils.errorHandleMethods(this)
        ClassUtils.deepFreeze(this)
    }

    deepFreeze() { return ClassUtils.deepFreeze(this) }
}

// finalize PureClass
ClassUtils.setClassProps(PureClass, { name: 'PureClass' })
ClassUtils.errorHandleMethods(PureClass)
ClassUtils.deepFreeze(PureClass)








/************************/
/******* EXAMPLES *******/
/************************/


// BADLY written class
class Height {
    constructor({ height = 180 } = {}) {
        this.height = height + 1000
    }

    getHeight() { return `Height: ${this.height}` }

    throwErrorForHeight() {
        throw new Error('Error from instance of Height method')
    }
}
// BADLY written class
class Weight {
    constructor({ weight = 100 } = {}) {
        this.weight = weight + ' kg'
    }

    getWeight() { return `Weight: ${this.weight}` }

    static throwErrorForWeight() {
        throw new Error('Error from Weight method')
    }
}

// WELL written class
const Person = class Self extends PureClass {
    constructor(...args) {
        super(...args)

        const props = args[0] || {}

        Object.assign(this, {
            name: props.name || 'John',
            age: props.age || 20
        })

        this.deepFreeze()
    }

    // Uncomment to replace the inherited one
    getHeight() { return 'Correct height' }

    // combines native with inherited methods
    greet() { console.log(`Hello, ${this.name}. ${this.getWeight()}, ${this.getHeight()}`) }

    // calculates the method name first
    ['get' + 'Info']() { return `Name: ${this.name}, age: ${this.age}` }    

    throwErrorForInstance() {
        throw new Error('Error shows up in instance methods')
    }

    onCatch(...args) {
        console.log(`On instance error in method with args: ${args}`)
        console.log(this)
    }

    // class methods
    static internalMethod() {
        return 'Hello from inside the class'
    }

    static throwErrorForPerson() {
        throw new Error('Error shows up in Person methods')
    }

    static onCatch(...args) {
        console.log(`On class error in method with args: ${args}`)
        console.log(this)
    }

    // can also use async, * generator
    // which can also be static
}

Person.finalizeClass({
    name: 'Person',
    inherited: [Height, Weight],
    props: { species: 'humans' }
})


const mark = new Person({ name: 'Mark', weight: 70 })
// copy mark props and replace some of them
const fatMark = new Person({ ...mark.args[0], weight: 110 })


const UncaughtErrorHandler = class Self extends PureClass {
    constructor(props = {}) {
        super(props)

        Object.assign(this, {
            app: props.app,
            server: props.server,
            port: props.port || 3000,
            sockets: new Set()
        })
        Object.freeze(this)
    }    

    static onUncaughtError (eventOrError) {
        const { isNodeJS, isBrowser, logError } = ErrorHandlingUtils
        const funcDesc = 'The app crashed, please restart!'

        if (isBrowser) {
            eventOrError.preventDefault()

            logError({ funcDesc, err: eventOrError.error || eventOrError.reason })

            // prevent user from interacting with the page
            window.document.body.style['pointer-events'] = 'none'
        }

        if (isNodeJS) {
            if (this.server === Object(this.server) && this.server.close) {
                this.server.close()
            }
            if (this.sockets instanceof Set) {
                this.sockets.forEach(socket => { socket.destroy() })
            }

            let exitCode = 0

            if (eventOrError instanceof Error) {
                exitCode = 1
                logError({ funcDesc, err: eventOrError })
            }

            setTimeout(() => { process.exit(exitCode) }, 1000).unref()
        }
    }

    static errorHandleServer() {
        const { isNodeJS } = ErrorHandlingUtils

        if (isNodeJS && this.server === Object(this.server)) {
            this.server.on('connection', socket => {
                this.sockets.add(socket);

                socket.on('close', () => { this.sockets.delete(socket) })
            })

            this.server.listen(this.port, err => {
                if (err) throw err
                console.log(`Server listening on ${this.port}`)
            })
        }
    }

    wrapApp(method, path, onTry) {
        const { createFunc } = ErrorHandlingUtils

        if (
            typeof method !== 'string' ||
            typeof path !== 'string' ||
            typeof onTry !== 'function' ||
            this.app !== Object(this.app)
        ) {
            return
        }

        this.app[method](path, createFunc(
            `app.${method}('${path}')`,
            onTry,
            (req, res, next) => {
                if (!res.headersSent) {
                    res.status(500).json({ message: 'Server error' })
                }
            }
        ))
    }

    initUncaughtErrorHandling() {
        const { isNodeJS, isBrowser } = ErrorHandlingUtils
        const errorFunc = Self.onUncaughtError.bind(this)

        if (isBrowser) {
            window.addEventListener('error', errorFunc, true)
            window.addEventListener('unhandledrejection', errorFunc, true)
        }

        if (isNodeJS) {
            Self.errorHandleServer.call(this)

            process.on('uncaughtException', errorFunc)
            process.on('unhandledRejection', errorFunc)
            process.on('SIGTERM', errorFunc)
            process.on('SIGINT', errorFunc)
        }
    }
}

UncaughtErrorHandler.finalizeClass({ name: 'UncaughtErrorHandler' })


const { isNodeJS, isBrowser, createFunc } = ErrorHandlingUtils

if (isBrowser) {
    const { initUncaughtErrorHandling } = new UncaughtErrorHandler()

    initUncaughtErrorHandling()
}

if (isNodeJS) {
    const http = require('http')
    const express = require('express')
    const app = express()
    const { initUncaughtErrorHandling, wrapApp } = new UncaughtErrorHandler({
        app,
        server: http.createServer(app),
        port: 8080
    })

    wrapApp('use', '/', express.urlencoded({ extended: true }))
    wrapApp('use', '/', express.json())
    wrapApp('use', '/', (req, res, next) => {
        res.set('Access-Control-Allow-Origin', '*')
        res.set(
            'Access-Control-Allow-Headers',
            'Origin, X-Requested-With, Content-Type, Accept'
        )
        next()
    })

    wrapApp('get', '/', (req, res, next) => {
        res.send('Hello World!')

        throw new Error('whoops')
    })

    wrapApp('get', '/err', async (req, res, next) => {
        await new Promise(resolve => setTimeout(resolve, 1000))

        throw new Error('Async whoops')
    })

    app.get('/uncaught', async (req, res, next) => {
        throw new Error('Is uncaught error')
    })

    wrapApp('all', '*', (req, res, next) => {
        res.status(404).json({ message: 'Page not found' })
    })

    initUncaughtErrorHandling()
}

const printNum = createFunc(
    'Printing a number',
    num => {
        blabla
        return num
    },
    num => {
        console.log(`Ran inside catch - the argument was ${num}`)
        return 0
    }
)

const measureFib = createFunc(
    'Measuring time for fibonacci number',
    num => {
        const fib = n => {
            if (n < 0 || Math.trunc(n) !== n)
                throw new Error('num had to be positive integer')

            return n <= 1 ? n : fib(n-1) + fib(n-2)
        }

        const startTime = Date.now()	

        try {
            return fib(num)
        } finally {
            console.log(`execution time ${Date.now() - startTime}ms`)
        }
    },
    () => 'Incorrect fibonacchi calculation'
)

const delayReturn = createFunc(
    'Delaying async function',
    async (ms) => {
        await new Promise(resolve => setTimeout(resolve, ms))

        if (typeof ms === 'number')
            return 'Proper result'
        else
            throw new Error('Async error from promise')
    },
    () => 'Default result'
)

const undefinedFunc = createFunc()

console.log('undefinedFunc(31)', undefinedFunc(31))
console.log('printNum(9)', printNum(9))
delayReturn(10).then(val => console.log('delayReturn(10) ' + val))
console.log('measureFib(35)', measureFib(35))
console.log(
    'measureFib({ a: [ 2, 5, { b: { c: 123 } } ] }, -32.55)',
    measureFib({ a: [ 2, 5, { b: { c: 123 } } ] }, -32.55)
)
console.log('measureFib(-12)', measureFib(-12))
console.log('\nThe program continues...')
delayReturn('invalid ms').then(val => console.log('delayReturn("invalid ms")', val))
//new Promise(() => { uncaughtAsyncFunc() })
//setTimeout(() => { uncaughtSyncFunc() }, 500)
