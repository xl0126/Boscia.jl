# GreaterThan
function MOI.add_constraint(
    optimizer::Optimizer,
    variable::MOI.VariableIndex,
    set::MOI.GreaterThan{Float64},
)
    return MOI.add_constraint(optimizer.model, variable, set)
end

function MOI.get(
    optimizer::Optimizer, 
    ::MOI.NumberOfConstraints{MOI.VariableIndex, MOI.GreaterThan{Float64}},
)::Int
    return MOI.get(
        optimizer.model, 
        MOI.NumberOfConstraints{MOI.VariableIndex, MOI.GreaterThan{Float64}}(),
    )
end 


# LessThan
function MOI.add_constraint(
    optimizer::Optimizer,
    variable::MOI.VariableIndex,
    set::MOI.LessThan{Float64},
)
    return MOI.add_constraint(optimizer.model, variable, set)
end

function MOI.get(
    optimizer::Optimizer, 
    ::MOI.NumberOfConstraints{MOI.VariableIndex, MOI.LessThan{Float64}},
)::Int
    return MOI.get(
        optimizer.model, 
        MOI.NumberOfConstraints{MOI.VariableIndex, MOI.LessThan{Float64}}(),
    )
end 

# interval
function MOI.add_constraint(
    optimizer::Optimizer,
    variable::MOI.VariableIndex,
    set::MOI.Interval{Float64},
)
    return MOI.add_constraint(optimizer.model, variable, set)
end

function MOI.get(
    optimizer::Optimizer, 
    ::MOI.NumberOfConstraints{MOI.VariableIndex, MOI.Interval{Float64}},
)::Int
    return MOI.get(
        optimizer.model, 
        MOI.NumberOfConstraints{MOI.VariableIndex, MOI.Interval{Float64}}(),
    )
end 

# EqualTo
function MOI.add_constraint(
    optimizer::Optimizer,
    variable::MOI.VariableIndex,
    set::MOI.EqualTo{Float64},
)
    return MOI.add_constraint(optimizer.model, variable, set)
end

function MOI.get(
    optimizer::Optimizer, 
    ::MOI.NumberOfConstraints{MOI.VariableIndex, MOI.EqualTo{Float64}},
)::Int
    return MOI.get(
        optimizer.model, 
        MOI.NumberOfConstraints{MOI.VariableIndex, MOI.EqualTo{Float64}}(),
    )
end 

# Integer 
function MOI.add_constraint(
    optimizer::Optimizer,
    variable::MOI.VariableIndex,
    set::MOI.Integer,
)
    return MOI.add_constraint(optimizer.model, variable, set)
end

function MOI.get(
    optimizer::Optimizer, 
    ::MOI.NumberOfConstraints{MOI.VariableIndex, MOI.Integer },
)::Int
    return MOI.get(
        optimizer.model, 
        MOI.NumberOfConstraints{MOI.VariableIndex, MOI.Integer}(),
    )
end 

# ZeroOne
function MOI.add_constraint(
    optimizer::Optimizer,
    variable::MOI.VariableIndex,
    set::MOI.ZeroOne,
)
    return MOI.add_constraint(optimizer.model, variable, set)
end

function MOI.get(
    optimizer::Optimizer, 
    ::MOI.NumberOfConstraints{MOI.VariableIndex, MOI.ZeroOne },
)::Int
    return MOI.get(
        optimizer.model, 
        MOI.NumberOfConstraints{MOI.VariableIndex, MOI.ZeroOne}(),
    )
end 

# supports_constraint
function MOI.supports_constraint(
    optimizer::Optimizer,
    ::Type{MOI.VariableIndex},
    ::Type{S}
) where{
    S<:Union{
            MOI.GreaterThan{Float64},
            MOI.LessThan{Float64},
            MOI.EqualTo{Float64},
            MOI.Interval{Float64},
            MOI.Integer,
            MOI.ZeroOne
    },
}
        

    return supports_constraint(
        optimizer.backend,
        MOI.VariableIndex,
        S,
    )
    
end


# ScalarAffineFunction
# GreaterThan
function MOI.add_constraint(
    optimizer::Optimizer,
    func::MOI.ScalarAffineFunction{Float64},
    set::MOI.GreaterThan{Float64},
)
    return MOI.add_constraint(optimizer.model, func, set)
end

function MOI.get(
    optimizer::Optimizer,
    ::MOI.NumberOfConstraints{
        MOI.ScalarAffineFunction{Float64},
        MOI.GreaterThan{Float64}
    },
)::Int
    return MOI.get(
        optimizer.model,
        MOI.NumberOfConstraints{
            MOI.ScalarAffineFunction{Float64},
            MOI.GreaterThan{Float64}
        }(),
    )
end

# LessThan
function MOI.add_constraint(
    optimizer::Optimizer,
    func::MOI.ScalarAffineFunction{Float64},
    set::MOI.LessThan{Float64},
)
    return MOI.add_constraint(optimizer.model, func, set)
end

function MOI.get(
    optimizer::Optimizer,
    ::MOI.NumberOfConstraints{
        MOI.ScalarAffineFunction{Float64},
        MOI.LessThan{Float64}
    },
)::Int
    return MOI.get(
        optimizer.model,
        MOI.NumberOfConstraints{
            MOI.ScalarAffineFunction{Float64},
            MOI.LessThan{Float64}
        }(),
    )
end

# EqualTo
function MOI.add_constraint(
    optimizer::Optimizer,
    func::MOI.ScalarAffineFunction{Float64},
    set::MOI.EqualTo{Float64},
)
    return MOI.add_constraint(optimizer.model, func, set)
end


function MOI.get(
    optimizer::Optimizer,
    ::MOI.NumberOfConstraints{
        MOI.ScalarAffineFunction{Float64},
        MOI.EqualTo{Float64}
    },
)::Int
    return MOI.get(
        optimizer.model,
        MOI.NumberOfConstraints{
            MOI.ScalarAffineFunction{Float64},
            MOI.EqualTo{Float64}
        }(),
    )
end

# supports_constraint
function MOI.supports_constraint(
    optimizer::Optimizer,
    ::Type{MOI.ScalarAffineFunction{Float64}},
    ::Type{S}
) where{
    S<:Union{
            MOI.GreaterThan{Float64},
            MOI.LessThan{Float64},
            MOI.EqualTo{Float64},
    },
}
        
    return supports_constraint(
        optimizer.backend,
        MOI.ScalarAffineFunction{Float64},
        S,
    )
end


# Constraint routing
function build_feasible_region(src::Optimizer)
    filtered_src = MOI.Utilities.ModelFilter(src.model) do item
        return !(
            item isa MOI.ObjectiveSense ||
            item isa MOI.ObjectiveFunction
        )
    end
    return filtered_src
end
