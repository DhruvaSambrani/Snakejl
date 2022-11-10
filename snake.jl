using DataStructures

function clc()
    if Sys.iswindows()
        return read(run(`powershell cls`), String)
    elseif Sys.isunix()
        return read(run(`clear`), String)
    elseif Sys.islinux()
        return read(run(`printf "\033c"`), String)
    end
end

KEYBIND = Dict(
        'a' => (0, -1),
        'w' => (-1, 0),
        'd' => (0, 1),
        's' => (1, 0),
)

abstract type AbstractFruit end
char(f::AbstractFruit) = f.char
loc(f::AbstractFruit) = f.loc

struct Apple <: AbstractFruit
    char::Char
    loc::CartesianIndex{2}
    Apple(loc) = new('a', loc)
end

mutable struct SnakeGame
    snake::CircularBuffer{CartesianIndex{2}}
    size::Tuple{Int, Int}
    direction::Tuple{Int, Int}
    grid::Matrix{Char}
    fruit::Union{AbstractFruit, Nothing}
    function SnakeGame(size::Tuple{Int, Int})
        snake = CircularBuffer{CartesianIndex{2}}(5)
        pushfirst!(snake, CartesianIndex(size .÷ 2))
        direction = (-1, 0)
        grid = fill('_', size)
        new(snake, size, direction, grid, nothing) 
    end
end

function effect!(f::AbstractFruit, sg::SnakeGame)
    newsnake = CircularBuffer{CartesianIndex{2}}(capacity(sg.snake) + 1)
    append!(newsnake, sg.snake)
    sg.snake = newsnake
end

function newfruit!(sg::SnakeGame)
    type = rand(subtypes(AbstractFruit))
    sg.fruit = type(CartesianIndex(rand.(Base.OneTo.(sg.size))))
    return
end

function draw(sg::SnakeGame)
    clc()
    sg.grid .= '_'
    sg.grid[sg.snake] .= 'o'
    sg.grid[first(sg.snake)] = '#'
    sg.grid[loc(sg.fruit)] = char(sg.fruit)
    println("Current length: ", length(sg.snake))
    println(join(reduce(*, sg.grid, dims=2), "\n"))
end

function move(sg::SnakeGame)
    newhead = CartesianIndex(mod1.((Tuple(first(sg.snake)) .+ sg.direction), sg.size))
    if newhead in sg.snake[1:end-1]
        return false
    else
        pushfirst!(sg.snake, newhead)
        if newhead == loc(sg.fruit)
            effect!(sg.fruit, sg)
            newfruit!(sg)
        end
        return true
    end
end

function changedir!(sg::SnakeGame, c::Char)
    newdir = get(KEYBIND, c, sg.direction)
    if (newdir .+ sg.direction) == (0, 0)
        newdir = sg.direction
    end
    sg.direction = newdir
end

function main()
    sg = SnakeGame((10, 20))
    newfruit!(sg)
    st = true
    draw(sg)
    while st
        _i = readline()
        i = length(_i) == 0 ? ' ' : _i[1]
        changedir!(sg, i)
        st = move(sg)
        draw(sg)
    end
    println("GAME OVER!")
end
main()
