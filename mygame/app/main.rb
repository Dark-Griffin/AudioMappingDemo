def tick args
  # Audio Mapping Demo
  # by Dark Griffin

  # #############################################
  # instructions
  args.outputs.labels  << [640, 700, 'Audio Mapping', 5, 1]
  args.outputs.labels  << [640, 670, 'by Dark Griffin', 5, 1]
  args.outputs.labels << [640, 640, 'Click to place listener', 5, 1]
  args.outputs.labels << [640, 610, 'Use arrow keys to rotate listener facing angle', 5, 1]
  args.outputs.labels << [640, 580, 'Hear how the sound playback points change based on where listener is', 5, 1]

  # #############################################
  # listener system logic and data

  # first we need to define our audio map
  args.state.audio_map ||= {}
  # define listener position and facing angle, so we can calculate what we hear
  args.state.listener ||= { x: 640, y: 360, angle: 0 }
  
  # lets define some sounds and where they are in the world
  # we can define this with a sound file path and a position x and y to place them on our map
  # we also define a playback delay, this will control how often the sound is played from that point in space.
  # each will need an angle value for use later in the system when we calculate the angle from the listener to the sound, and a distance value to control volume.
  # also, we need a max cutoff distance, this is used to give a range for "I can hear this sound", and if distance is greater than this, we don't play the sound.
  args.state.audio_map[:sound1] = { path: 'sounds/splash.wav', x: 100, y: 100, delay: 2.0, angle: 0.0, distance: 0.0, max_distance: 100 }
  #args.state.audio_map[:sound2] = { path: 'sounds/spring.wav', x: 350, y: 400, delay: 1.0, angle: 0.0, distance: 0.0, max_distance: 100 }
  #args.state.audio_map[:sound3] = { path: 'sounds/tada.wav', x: 700, y: 100, delay: 4.0, angle: 0.0, distance: 0.0, max_distance: 100 }
  #args.state.audio_map[:sound4] = { path: 'sounds/tink.wav', x: 650, y: 400, delay: 0.5, angle: 0.0, distance: 0.0, max_distance: 100 }

  
  # for each audio in audio_map, set the listening angle from the player position
  args.state.audio_map.each do |key, value|
    # calculate the angle from the sound to the listener
    value[:angle] = Math.atan2(args.state.listener.y - value[:y], args.state.listener.x - value[:x])
    # also calculate the distance from the listener to the sound
    value[:distance] = Math.sqrt((value[:x] - args.state.listener.x) ** 2 + (value[:y] - args.state.listener.y) ** 2)
  end

  # todo for me
  # - figure out listening pan from angle of sound relative to the listener
  # - figure out listening volume from distance of sound relative to the listener
  # - output sounds and play them based on the above calculations
  # - keep track of ticks per sound so we can play the sounds at the specified delay times

  # for each sound in the audio_map, we need to get the angle between 0 and 180 degrees.  We also need to convert the backwards angles to be positive.  Then we need to store each angle relative to the listener angle so that the final resulting value is a measure of the angle between 0 and 1280 in audio pixel position space instead.
  args.state.audio_map.each do |key, value|
    panning_angle = value[:angle] - args.state.listener.angle
    #flip angle along the axis if it is over 180 degrees in either rotation direction
    if panning_angle > Math::PI / 2
      panning_angle = -panning_angle + (Math::PI)
    end
    if panning_angle < -Math::PI / 2
      panning_angle = -panning_angle - (Math::PI)
    end
    
    #convert angle Math::PI /2 to 0 to 1280 range
    panning_angle = (panning_angle + Math::PI / 2) / Math::PI * 1280
    #store the angle in the audio_map
    value[:panning_angle] = panning_angle
  end
  
  # debug, show the panning_angle as a string on screen
  args.outputs.labels << [640, 550, "panning_angle: #{args.state.audio_map[:sound1][:panning_angle]}", 5, 1]
  # debug, show listener angle
  args.outputs.labels << [640, 520, "listener angle: #{args.state.listener.angle}", 5, 1]

  # #############################################
  # interactions

  # click to place listener
  if args.inputs.mouse.click
    args.state.listener.x = args.inputs.mouse.click.point.x
    args.state.listener.y = args.inputs.mouse.click.point.y
  end

  # use arrow keys to rotate listener facing angle
  if args.inputs.keyboard.key_held.left
    args.state.listener.angle -= 0.01
  end
  if args.inputs.keyboard.key_held.right
    args.state.listener.angle += 0.01
  end
  # correct for angle overflow
  if args.state.listener.angle > Math::PI
    args.state.listener.angle -= Math::PI * 2
  end
  if args.state.listener.angle < -Math::PI
    args.state.listener.angle += Math::PI * 2
  end

  # #############################################
  # debugging visuals to aid in seeing what we are doing

  # for visual purposes, we render a dot at each sound location so we can visualize the data
  args.outputs.solids << args.state.audio_map.map do |key, value|
    [value[:x], value[:y], 10, 10, 155, 0, 0]
  end

  # for each audio dot, also render the angle out as a line of length equal to distance calculation
  args.outputs.lines << args.state.audio_map.map do |key, value|
    #if the listen distance is greater than the max distance, render it as a red line
    if value[:distance] > value[:max_distance]
      [value[:x] + 5, value[:y] + 5, value[:x] + 5 + value[:distance] * Math.cos(value[:angle]), value[:y] + 5 + value[:distance] * Math.sin(value[:angle]), 255, 0, 0]
    else
      [value[:x] + 5, value[:y] + 5, value[:x] + 5 + value[:distance] * Math.cos(value[:angle]), value[:y] + 5 + value[:distance] * Math.sin(value[:angle]), 0, 0, 255]
    end
  end

  # render a dot at the listener position with a line showing the angle they are facing
  args.outputs.solids << [args.state.listener.x, args.state.listener.y, 10, 10, 0, 155, 0]
  args.state.debug_lineLength ||= 50
  args.state.debug_lineColor ||= [0, 155, 0]
  args.outputs.lines << [args.state.listener.x + 5, args.state.listener.y + 5, args.state.listener.x + 5 + args.state.debug_lineLength * Math.cos(args.state.listener.angle), args.state.listener.y + 5 + args.state.debug_lineLength * Math.sin(args.state.listener.angle), *args.state.debug_lineColor]

end
