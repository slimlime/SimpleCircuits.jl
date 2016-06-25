# each component must specify IV (current-voltage) relations
# for a two port component, we only require one IV relation
# for a three port component, we require two, etc
# NOTE: for perfect voltage sources, clearly we don't have an
# IV relation - so for these, we use the obvious node voltage relation
# and a "dummy" current variable when constructing the linear system.

# note these are DC relations, so for capacitors we have an open circuit
# and for inductors we have a short circuit

# the functions should return an expression for the current through the device
# in terms of the provided symbols

# I'm not really worried about type stability here because these are just used
# for building the function for the system of equations for a given circuit,
# and the corresponding Jacobian matrix function - so it's a bit like a compiler

typealias PortSyms Dict{Port, Symbol}

# IV relations for a voltage source
# in this case, we don't use most of the interface because all we're returning is the 
# dummy current - but we could also use this to specify an implicit current relation
# (like I = exp(I) or something ...)
function dciv(comp::DCVoltageSource, ps::PortSyms, pIn::Port, currentSym::Symbol = :I)
    
    # return the current symbol, taking into account the direction
    # using the provided in port as a reference
    # (the dummy current always goes from pLow to pHigh)
    sgn = pIn == comp.pLow ? 1. : -1.
    return :($(sgn) * $(currentSym))
end

function dciv_diff(comp::DCVoltageSource, ps::PortSyms, pIn::Port, wrt::Symbol, 
    currentSym::Symbol = :I)
    
    @assert wrt in values(ps) || wrt == currentSymbol

    # return the (partial) derivative of the directed current with respect to 
    # the given symbol - in this case, current does not depend on the voltages
    if wrt == currentSym
        return pIn == comp.pLow ? 1. : -1.
    else
        return 0.
    end
end

# other equations to satisfy for a DC voltage source (equation is expression = 0)
function dcsatisfy(comp::DCVoltageSource, ps::PortSyms, currentSym::Symbol = :I)
    return [:($(ps[comp.pHigh]) - $(ps[comp.pLow]) - $(comp.V))]
end

# return the partial derivative of EVERY "other equation" w.r.t the given symbol
function dcsatisfy_diff(comp::DCVoltageSource, ps::PortSyms, wrt::Symbol, 
    currentSym::Symbol = :I)
    
    @assert wrt in ps || wrt == currentSym
    @assert pIn == comp.p1 || pIn == comp.p2

    if wrt == ps[comp.pHigh]
        eqn1_diff = 1.
    elseif wrt == ps[comp.plow]
        eqn1_diff = -1.
    elseif wrt == currentSym
        eqn1_diff = 0.
    end
    
    return [eqn1_diff]
end

# DC IV relation for a resistor (V = IR)
function dciv(comp::Resistor, ps::PortSyms, pIn::Port, currentSym::Symbol = :I)
    
    # ensure the port belongs to the component
    @assert pIn == comp.p1 || pIn == comp.p2

    # ensure the port is in the given dictionary
    @assert pIn in keys(ps)

    # return the expression for the currents
    return :(($(ps[pIn]) - $(ps[other_port(pIn)])) / $(comp.R))
end

function dciv_diff(comp::Resistor, ps::PortSyms, pIn::Port, wrt::Symbol, 
    currentSym::Symbol = :I)
    
    @assert wrt in values(ps) || wrt == currentSymbol
    
    # derivative of (v_pIn - v_pOut) / R w.r.t the given port
    if wrt == currentSymbol
        return 0.
    else
        if wrt == ps[pIn]
            return :(1 / $(comp.R))
        else
            return :(-1 / $(comp.R))
        end
    end
end

# other equations to satisfy for a resistor (none in this case)
function dcsatisfy(comp::Resistor, ps::PortSyms, currentSym::Symbol = :I)
    return Expr[]
end

# nothing to do here
function dcsatisfy_diff(comp::Resistor, ps;:PortSyms, wrt::Symbol, 
    currentSym::Symbol = :I)

    return Expr[]
end

# DC IV relation for a capacitor - treat it as an open circuit (current = 0)
function dciv(comp::Capacitor, ps::PortSyms, pIn::Port, currentSym::Symbol = :I)

    return 0.
end

# (derivative of 0 is 0 ...)
function dciv_diff(comp::Capacitor, ps::PortSyms, pIn::Port, 
    currentSym::Symbol = :I)

    return 0.
end

# no other DC relations for a capacitor
function dcsatisfy(comp::Capacitor, ps::PortSyms, currentSym::Symbol = :I)

    return Expr[]
end

# ...
function dcsatisfy_diff(comp::Capacitor, ps::PortSyms, currentSymbol::Symbol = :I)
    
    return Expr[]
end

# DC IV relation for an inductor - treat it as a short circuit (voltage across it = 0)
function dciv(comp::Inductor, ps::PortSyms, pIn::Port, currentSym::Symbol = :I)

    # dummy currents for inductors now go from p1 to p2
    sgn = pIn == comp.p1 ? 1. : -1.
    return :($(sgn) * $(currentSym))
end

function dciv_diff(comp::Inductor, ps::PortSyms, pIn::Port, wrt::Symbol,
    currentSym::Symbol = :I)

    # very similar to DCVoltageSource
    if wrt == currentSym
        return pIn == comp.p1 ? 1. : -1.
    else
        return 0.
    end
end

# no other DC relations for an inductor
function dcsatisfy(comp::Inductor, ps::PortSyms, currentSym::Symbol = :I)

    return Expr[]
end

# ...
function dcsatisfy_diff(comp::Inductor, ps::PortSyms, currentSymbol::Symbol = :I)
    
    return Expr[]
end
