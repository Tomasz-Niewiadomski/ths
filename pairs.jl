using Plots
using Random

dt = 0.06 ; δt = 0.5 ; v_0 = 120; 
input_choice = true; sim_time = 15;

t = 0:dt:(sim_time + δt - 1);δt_idx = length(0:dt:δt);

function update(ActiveParticle, dt, δt, v_0 = 2)
	r_0 = first(ActiveParticle.r)
	r_last = last(ActiveParticle.r)

	ω_0 = v_0 / r_last
	θ_func(ϕ_new, ϕ_old, input) = ϕ_new - ϕ_old + input
	ω_func(θ_func) = ω_0 * sin(θ_func)

	function input_signal(time)
		if input_choice == true
			return sin(time) + 2*cos(3time)*sin(time)
		else
			return 0*time
		end
	end

	for i in 1:length(t)
		argument = θ_func(ActiveParticle.ϕ[i+δt_idx], ActiveParticle.ϕ[i], input_signal(i))

		r_last = last(ActiveParticle.r) - v_0 * cos(argument) * dt

		if r_last < r_0
			r_last = r_0
		end

		push!(ActiveParticle.r, r_last)
		push!(ActiveParticle.ϕ, last(ActiveParticle.ϕ) + ω_func(argument) * dt)
		push!(ActiveParticle.θ, argument)
	end
end

mutable struct ActiveParticle
	r::Vector{Float64} # Initial radius
	ϕ::Vector{Float64}
	θ::Vector{Float64}
	colour::String
end

AP1 = ActiveParticle(Float64[30], push!(zeros(length(0:dt:δt)), rand()), Float64[], "darkblue");
AP2 = ActiveParticle(Float64[30], push!(zeros(length(0:dt:δt)), rand()), Float64[], "darkblue");

update(AP1, dt, δt, v_0) ; update(AP2, dt, δt, v_0)

begin
	p1a = plot(t,AP1.θ .* 180/pi,xlabel="time t [s]" , ylabel="θ [∠]",w=3.,colour="darkgreen",legend=false, title = "Particle 1")
	p2a = plot(t,AP1.ϕ[δt_idx+1:length(AP1.ϕ)-1] .* 180/pi ,xlabel="time t [s]" , ylabel="ϕ [∠]",w=3.,colour="darkred",legend=false)
	p3a = plot( t , AP1.r[1:end-1] ,xlabel="time t [s]" , ylabel="radius [m]",w=3.,colour="darkblue",legend=false)
	
	p1b = plot(t,AP2.θ .* 180/pi,xlabel="time t [s]" , ylabel="θ [∠]",w=3.,colour="darkgreen",legend=false, title = "Particle 2")
	p2b = plot(t,AP2.ϕ[δt_idx+1:length(AP2.ϕ)-1] .* 180/pi ,xlabel="time t [s]" , ylabel="ϕ [∠]",w=3.,colour="darkred",legend=false)
	p3b = plot( t , AP2.r[1:end-1] ,xlabel="time t [s]" , ylabel="radius [m]",w=3.,colour="darkblue",legend=false)
	
	plot(p1a, p1b, p2a, p2b,p3a, p3b, layout=(3,2),dpi=300,size = (680,600))
end