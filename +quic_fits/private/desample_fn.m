function signal_ds = desample_fn(signal,factor)
    % reduce number of points in vector for faster fitting

    signal_ds = signal(1:factor:end);

end