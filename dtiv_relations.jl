# contains time derivatives of IV relations 
# two different functions here: one returns the symbol 

# these are in some way a generalization of dciv relations

# and for most components, they will be exactly the same as the dciv relations
function dtiv(comp::Component, ps::PortSyms, dtps::PortSyms, pIn::Port, 
    currentSym = :I, dtcurrentSym = :I_)

    return dciv(comp, ps, pIn, currentSym)
end

# we need to generalize all four functions
function dtiv_diff(comp::Component, ps::PortSyms, dtps::PortSyms, pIn::Port, wrt, 
    currentSym = :I, dtcurrentSym = :I_)

    return dciv_diff(comp, ps, pIn, wrt, currentSym)
end

function dtsatisfy(comp::Component, ps::PortSyms, dtps::PortSyms, currentSym = :I)

    return dcsatisfy(comp, ps, currentSym)
end

function dtsatisfy_diff(comp::Component, ps::PortSyms, dtps::PortSyms, wrt, currentSym = :I)

    return dcsatisfy_diff(comp, ps, wrt, currentSym)
end

# CAREFUL! DC components with dummy currents need to be accounted for
#function dtiv_diff(comp::DCVoltageSource, ps::PortSyms, dtps::PortSyms, pIn::Port, wrt,
#    currentSym = :I, dtcurrentSym = :I_)
#    
#    #if wrt != currentSym end
#    #if pIn == p1(comp)
#    #    return 
#end

# but for some components - capacitors, inductors, and variable voltage 
# and current sources, there will be differences
function dtiv(comp::Capacitor, ps::PortSyms, dtps::PortSyms, pIn::Port, 
    currentSym = :I, dtcurrentSym = :I_)

    sgn = pIn == p1(comp) ? 1. : -1.

    return :($(sgn) * $(comp.C) * ($(dtps[pIn]) - $(dtps[other_port(pIn)])))
end

function dtiv_diff(comp::Capacitor, ps::PortSyms, dtps::PortSyms, pIn::Port, wrt, 
    currentSym = :I, dtcurrentSym = :I_)
    
    # confusing ... what if wrt == ps[p1(comp)] ? => is (d/dx) (dx/dt) = 0? yes! (by linearity)
    if !(wrt == dtps[p1(comp)] || wrt == dtps[p2(comp)]) return 0. end

    sgn = pIn == p1(comp) ? 1. : -1.
    sgn *= wrt == dtps[p1(comp)] ? 1. : -1.

    return :($(sgn) * $(comp.C))
end

function dtsatisfy(comp::Capacitor, ps::PortSyms, dtps::PortSyms, currentSym = :I)
    
    # nothing to do here
    return Expr[]
end

function dtsatisfy_diff(comp::Capacitor, ps::PortSyms, dtps::PortSyms, wrt, currentSym = :I)

    return Expr[]
end

# TODO: implement inductor relations if time allows

# for a variable voltage source:
function dtiv(comp::VoltageSource, ps::PortSyms, dtps::PortSyms, pIn::Port, 
    currentSym = :I, dtcurrentSym = :I_)
    
    # return the time derivative of the dummy current symbol with the appropriate sign
    if pIn == p1(comp)
        return :(-$(currentSym))
    else
        return currentSym
    end
end

function dtsatisfy(comp::VoltageSource, ps::PortSyms, dtps::PortSyms, 
    currentSym = :I, dtcurrentSym = :I_)
    
    return [:($(ps[p1(comp)]) - $(ps[p2(comp)]) - $(comp.V))]
end