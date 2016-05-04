#11045744
begin
  module PBWeather
    SUNNYDAY  = 1
    RAINDANCE = 2
    SANDSTORM = 3
    HAIL      = 4
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end