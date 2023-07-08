/*
'Green vs Red' is a  game played on a 2D grid that in theory can be infinite (in our case we will assume that x <= y < 1000).
Each cell on this grid can be eeither green (represented by 1) or red (represented by 0). The game always receives an initial state of the grid which we will call 'Generation Zero'. After that a set of 4 rules are applied across the grid and those rules form the next generation.

Rules that create the next generation:
1. Each red cell that is surrounded by exactly 3 or exactly 6 green cells will also become green in the next generation.
2. A red cell will stay red in the next generation if it has either 0, 1, 2, 4, 5, 7, 8 green neighbours.
3. Each green cell surrounded by 0, 1, 4, 5, 7, 8 green neigbours will become red in the next generation.
4. A green cell will stay green in the next generation if it has either 2, 3, 6 green neighbours.

Important facts:
- Each cell can be surrounded by up to 8 cells: 4 on the sides and 4 on the corners. Exceptions are the corners and the sides of the grid.
- All the 4 rules apply at the same time for the whole grid in order for the next generation to be formed.

Your task - create a program that accepts:
1. The size of our grid - x, y (x being the width and y being the height)
2. Then the next y lines should contain stirngs (long x characters) created by 0s and 1s which will represent the 'Generation Zero' state and help us build the grid.
3. The last arguments to the program should be coordinates (x1 and y1) and the number N.

(x1 and y1) will be coordinates of a cell in the grid. We would like to calculate in how many generations from Generation Zero untill generation N this cell was green.
(The calculation should include generation Zero and generation N).

Print your result in the console.

Special requirement: Write your game in a way that uses several classes. This will show OOp knowledge and will accound for more points during the evaluation.
Comments, good naming convention and documentation are also recommended.

Example 1:
// 3x3 grid, in the initial state, the second row is all 1s, how many times will the cell [1, 0] (top center) become green in 10 turns?
'3, 3'
'000'
'111'
'000'
'1, 0, 10'
//expected result: 5

Example 2:
/// 4x4 grid. Input:
'4, 4'
'1001'
'1111'
'0100'
'1010'
'2, 2, 15'
//expected result: 14
*/

const RETHROW = "__custom_string_for_error_rethrow__"

const catchFunc = (descr, func, errVal) => (...args) => {
    try {
        return func(...args)
    } catch(err) {
        if (errVal === RETHROW) {
            throw new Error(`While calling [${descr}]:\n  ${err.message}`)
        }

        console.error(`\n Issue at: ${descr}\n`, err, '\n')

        return errVal

    }
}

const addGreensForRow = catchFunc(
    "summing the green neighbours on a row (current, above or below)",
    ({ row, cellIdx, onNeighbourRow }) => {
        let greens = 0

        // should add the center cell
        if (onNeighbourRow)
            greens = greens + row[cellIdx]

        // should add the cell to the left
        if (row[cellIdx - 1] !== undefined)
            greens = greens + row[cellIdx - 1]

        // should add the cell to the right
        if (row[cellIdx + 1] !== undefined)
            greens = greens + row[cellIdx + 1]

        return greens
    },
    RETHROW
)

const getNextGrid = catchFunc(
    "creating next grid",
    grid => grid.map((row, rowIdx) => row.map((cell, cellIdx) => {
        // sum the green neigbours from the current, above and below rows
        const greenNeighbours = addGreensForRow({ row: grid[rowIdx], cellIdx, onNeighbourRow: false }) +
            (rowIdx > 0 ? addGreensForRow({ row: grid[rowIdx - 1], cellIdx, onNeighbourRow: true }) : 0) +
            (rowIdx < grid.length - 1 ? addGreensForRow({ row: grid[rowIdx + 1], cellIdx, onNeighbourRow: true }) : 0)

        // apply the rules for the game to the current cell without changing it yet
        return cell === 0 ?
            // in case the cell is red
            ([3, 6].includes(greenNeighbours) ? 1 : 0) :
            // in case the cell is green
            ([2, 3, 6].includes(greenNeighbours) ? 1 : 0)
    })),
    RETHROW
)

const calcTimesGreen = catchFunc(
    "calculating the times the cell was green",
    ({ x1, y1, timesToPlay, grid }) => {
        let timesGreen = 0

        while (timesToPlay--) {
            grid = getNextGrid(grid)

            if (grid[y1][x1] === 1)
                timesGreen++
        }

        return timesGreen
    },
    RETHROW
)

const greenVsRed = catchFunc(
    "solving GreenVsRed",
    (...args) => {
        if (args.length < 2 || args.some(arg => typeof arg !== "string")) {
            throw new Error("Arguments must be strings and more than 1")
        }

        // the coordinates for the cell to be watched and the number of times the grid must me changed
        const [x1, y1, timesToPlay] = args[args.length-1].split(/,\s*/).map(str => +str)

        const timesGreen = calcTimesGreen({
            x1, y1, timesToPlay,
            grid: args.slice(1, args.length - 1).map(row => row.split('').map(str => +str)),
        })

        return `The cell at coordinates [${x1}, ${y1}] has been green ${timesGreen} times`
    },
    "Error during calculation"
)

console.log("greenVsRed('3, 3', '000', '111', '000', '1, 0, 10'), result should be 5")
console.log(greenVsRed('3, 3', '000', '111', '000', '1, 0, 10'), '\n')

console.log("greenVsRed({}), result should be an error")
console.log(greenVsRed({}), '\n')

console.log("greenVsRed('4, 4', '1001', '1111', '0100', '1010', '2, 2, 15'), result should be 14")
console.log(greenVsRed('4, 4', '1001', '1111', '0100', '1010', '2, 2, 15'), '\n')
