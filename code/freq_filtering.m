
% sub-routine to do filtering
% created on 07 March 2016

function [sig] = freq_filtering(sig,h,ftimes)

    L = length(h);
    n = length(sig); p = L;
    
    if mod(p,2) == 1
        d1 = (p-1)/2; d2 = (p-1)/2;
    else
        d1 = p/2-1; d2 = p/2;
    end
    
    for j = 1:size(sig,2)
        for k = ftimes
            temp = [sig(d1:-1:1,j); sig(:,j); sig(end:-1:end-d2+1,j)];
            nx = length(temp);
            nh = length(h);
            nfft = 2^nextpow2(nx+nh-1);
            xzp = [temp; zeros(1,nfft-nx)'];
            hzp = [h'; zeros(1,nfft-nh)'];
            X = fft(xzp);
            H = fft(hzp);
            Y = H .* X;
            %format bank;
            y = real(ifft(Y)); % zero-padded result
            y = y(1:nx+nh-1); % trim and print

            sig(:,j) = y((2*d1+1):(2*d1+n));
        end
    end
    
end
