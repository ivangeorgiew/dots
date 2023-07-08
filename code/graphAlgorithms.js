const airports = 'PHX BKK OKC JFK LAX MEX EZE HEL LOS LAP LIM'.split(' ')
const routes = [
    ['PHX', 'LAX'],
    ['PHX', 'JFK'],
    ['JFK', 'OKC'],
    ['JFK', 'HEL'],
    ['JFK', 'LOS'],
    ['MEX', 'LAX'],
    ['MEX', 'BKK'],
    ['MEX', 'LIM'],
    ['MEX', 'EZE'],
    ['LIM', 'BKK'],
]

const createGraph = ({ nodes, edges }) => {
    const graph = {}

    // add nodes
    let i = 0

    while (nodes.length - i++) {
        graph[nodes[i]] = []
    }

    // add edges in both directions
    i = 0

    while (routes.length - i++) {
        const [a, b] = routes[i]

        graph[a].push(b)
        graph[b].push(a)
    }

    return graph
}

const airportRoutes = createGraph({ nodes: airports, edges: routes })

const breadthFirstSearch = ({ graph, start, end }) => {
    const queue = [start]
    const result = new Set()
    let queueIdx = 0

    while (queue.length - queueIdx++) {
        const curNode = queue[queueIdx]

        if (!result.has(curNode)) {
            result.add(curNode)

            if (end && curNode === end) {
                return result
            }

            let i = 0

            while (graph[curNode].length - i++) {
                const neigh = graph[curNode][i]

                if (!result.has(neigh)) {
                    queue.push(neigh)
                }
            }
        }
    }

    return result
}

const depthFirstSearch = ({ graph, start, end }) => {
    const queue = [start]
    const result = new Set()

    while (queue.length) {
        const curNode = queue.pop()

        if (!result.has(curNode)) {
            result.add(curNode)

            if (end && curNode === end) {
                return result
            }

            let i = graph[curNode].length

            while (i--) {
                const neigh = graph[curNode][i]

                if (!result.has(neigh)) {
                    queue.push(neigh)
                }
            }
        }
    }

    return result
}

console.log({
    graph: airportRoutes,
    bfs: breadthFirstSearch({ graph: airportRoutes, start: 'PHX', end: 'BKK' }),
    dfs: depthFirstSearch({ graph: airportRoutes, start: 'PHX', end: 'BKK' })
})
