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
  args.state.audio_map[:sound1] = { path: 'sounds/splash.wav', x: 100, y: 100, delay: 2.0 }
  args.state.audio_map[:sound2] = { path: 'sounds/spring.wav', x: 350, y: 400, delay: 1.0 }
  args.state.audio_map[:sound3] = { path: 'sounds/tada.wav', x: 700, y: 100, delay: 4.0 }
  args.state.audio_map[:sound4] = { path: 'sounds/tink.wav', x: 650, y: 400, delay: 0.5 }

  

  # #############################################
  # interactions

  # click to place listener
  if args.inputs.mouse.click
    args.state.listener.x = args.inputs.mouse.click.point.x
    args.state.listener.y = args.inputs.mouse.click.point.y
  end

  # #############################################
  # debugging visuals to aid in seeing what we are doing

  # for visual purposes, we render a dot at each sound location so we can visualize the data
  args.outputs.solids << args.state.audio_map.map do |key, value|
    [value[:x], value[:y], 10, 10, 155, 0, 0]
  end
end
