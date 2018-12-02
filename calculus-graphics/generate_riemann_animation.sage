#!/usr/bin/env sage

from sage.all import *

INTEGRATION_MODES = ('left', 'right', 'center')


def generate_riemann_frames(f, plot_interval, integral_interval, step_count, mode='left'):
    """
    Generate an animatable list of sage graphics demonstrating a riemann sum
    approximation of the integral of f.
    """
    frames = []
    a, b = integral_interval
    # name of the argument to the function f
    variable_name = str(f.variables()[0])
    # plot of the function f over in the interval p_all
    plot_f = plot(f, *plot_interval, zorder=2, legend_label='f({})={}'.format(variable_name, f))
    # Add title to the plot of f
    plot_f += text(
        'Visualization of Riemann Sum Approximation of $\int_{{{0:.1f}}}^{{{1:.1f}}} f({2}) d{2}$'.format(float(a), float(b), variable_name), 
        (0.5,1.05), 
        axis_coords=True, 
        fontsize='large',
        color='black',
    )
    integration_width = b - a
    actual_area = f.integrate(f.variables()[0], a, b)

    def box_under_area(start, end, mode = 'left'):
        if mode not in INTEGRATION_MODES:
            raise InvalidArgument('mode must be left, right, or center, {} recieved'.format(mode))
        height_argument = {'left': start, 'right': end, 'center': (start + end) / 2}[mode]
        height = f(**{variable_name: height_argument})
        points = [(start, 0), (start, height), (end, height), (end,0)]
        return (polygon(points, alpha=0.5, zorder=1), (end - start) * height)

    for step in range(1, step_count + 1):
        width = integration_width / step
        step_plot = plot_f  # begin with just background f
        step_area = 0
        
        for particular in range(1, step + 1):  # add n boxes under f where n = step
            box, area = box_under_area(a + (particular - 1) * width, a + particular * width, mode=mode)
            step_plot += box
            step_area += area
       
        area_text = text(
            '      Actual area: {}\nApproximated area: :{:1.4f}'.format(actual_area, float(step_area)), 
            (0.5,0.1),
            horizontal_alignment='center',
            bounding_box={'boxstyle':'round', 'fc':'w'},
            color='black',
            axis_coords=True,
            fontsize='medium',
        )
        frames.append(step_plot + area_text)
    return frames

def main(raw_args):
    """CLI entry point."""

    def real_interval(string):
        values = tuple(float(s) for s in string.strip('()[]').split(','))
        if len(values) != 2:
            raise argparse.ArgumentTypeError('{} is not a valid pair of real numbers'.format(string))
        return values

    def natural_number(string):
        i = int(string)
        if i <= 0:
            raise argparse.ArgumentTypeError('{} is not a valid positive integer'.format(string))
        return i

    parser = argparse.ArgumentParser(description='Generate GIF of riemann sum approximation for arbitrary functions.')
    parser.add_argument('output_file')
    parser.add_argument('--function', default='x*(x-2)*(x-1)+1')
    parser.add_argument('--plot-interval', type=real_interval, default=(0.0,2.0))
    parser.add_argument('--integral-interval', type=real_interval, default=(0.5,1.5))
    parser.add_argument('--step-count', type=natural_number, default=45)
    parser.add_argument('--mode', choices=INTEGRATION_MODES, default='left')
    parser.add_argument('--delay', type=natural_number, default=20)

    args = parser.parse_args(raw_args)
    
    # Create symbolic variables for all letters in the function string
    var(*[c for c in args.function if c.isalpha()])
    
    # Parse the function
    f = SR(args.function)

    # Generate the plots
    frames = generate_riemann_frames(f, args.plot_interval, args.integral_interval, args.step_count, args.mode)
    
    # Generate the animation
    animation = animate(frames)
    
    # Save the animation
    animation.gif(delay=args.delay, savefile=args.output_file)

if __name__ == '__main__':
    import argparse
    import sys

    main(sys.argv[1:])
