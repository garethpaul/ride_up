# frozen_string_literal: true

module DelayedMarkerContract
  module_function

  def failures(source)
    delayed_start = source.index('handler.postDelayed(new Runnable()')
    delayed_end = delayed_start && source.index('}, 500);', delayed_start)
    return ['MainActivity must retain the delayed marker runnable'] unless delayed_start && delayed_end

    runnable = source[delayed_start..delayed_end]
    guard = "if (!markerAnimationLifecycle.canAnimate()) {\n                                    return;\n                                }"
    loop_start = 'for (int i = 0; i < 10; i++)'
    marker_add = 'addRandomCar();'

    unless runnable.include?(guard) &&
           runnable.include?(loop_start) &&
           runnable.include?(marker_add) &&
           runnable.index(guard) < runnable.index(loop_start) &&
           runnable.index(loop_start) < runnable.index(marker_add)
      return ['Delayed marker population must reject inactive lifecycle state before map mutation']
    end

    []
  end
end
