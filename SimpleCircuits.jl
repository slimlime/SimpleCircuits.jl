# MATH3976 project - a simple circuit simulator for developing 
# analog circuit design intuition

module SimpleCircuits

# need stuff here like resistor, capacitor, inductor, diode, BJT, MOSFET, etc
include("components.jl")
export Circuit, Port, Resistor, Capacitor, Inductor, DCVoltageSource, DCCurrentSource
export TwoPortComponent

# methods for constructing circuits via connections
import Base.merge!
include("connections.jl")
export is_floating, node_name_in_use, is_connected, port_belongs
export merge!, connect!, disconnect!

# methods for expressions for DC IV (current-voltage) relations
# of various components
include("dciv_relations.jl")
export dciv, dcsatisfy, dciv_diff, dcsatisfy_diff
export PortSyms

# display methods
import Base.show
include("show.jl")
export show

# operating point analysis
include("op.jl")
export op

# include tests
include("tests/tests.jl")

end
