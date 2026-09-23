
function build_objective_oracles(optimizer::Optimizer)
    typ = MOI.get(optimizer, MOI.ObjectiveFunctionType())
    obj = MOI.get(optimizer, MOI.ObjectiveFunction{typ}())
    n = MOI.get(optimizer, MOI.NumberOfVariables())
    sense = MOI.get(optimizer, MOI.ObjectiveSense())
    
    if sense == MOI.MIN_SENSE 
        sign = 1.0
    elseif sense == MOI.MAX_SENSE
        sign = -1.0
    else
        error("Unsupported objective sense: $sense")
    end

    if typ == MOI.ScalarAffineFunction{Float64}
        q = zeros(Float64, n)

        for term in obj.terms
            q[term.variable.value] += term.coefficient
        end 

        c = obj.constant 

        f = x -> sign * (dot(q, x) + c)

        grad! = (storage, x) -> begin
            storage .= q
            storage .*= sign
            return storage
        end
        
        return f, grad!
    
    elseif typ == MOI.ScalarQuadraticFunction{Float64}
        Q = zeros(Float64, n, n)
        q = zeros(Float64, n)

        # Linear Part
        for term in obj.affine_terms
            q[term.variable.value] += term.coefficient
        end

        # Quadratic part 
        for term in obj.quadratic_terms
            i = term.variable_1.value
            j = term.variable_2.value
            a = term.coefficient

            if i == j
                Q[i, i] += a
            else
                Q[i, j] += a
                Q[j, i] += a
            end
        end

        c = obj.constant

        f = x -> sign * (0.5 * dot(x, Q, x) + dot(q, x) + c)

        grad! = (storage, x) -> begin
            mul!(storage, Q, x)
            storage .+= q
            storage .*= sign
            return storage 
        end
        
        return f, grad!

    else
        error("Unsupported objective type: $typ")
    end
end
            






