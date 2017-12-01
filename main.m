[stereo, Fs] = audioread('samp6.wav');

lv = ~sum(stereo == 0, 2);
v = sum(stereo, 2);
v(lv) = v(lv)/2;

%sampleLength = 30;
%v = v(1 : Fs * sampleLength);

wLength = 512;
w = hann(wLength);

[spec, F, T] = spectrogram(v, w, wLength * 0.75, 'yaxis');
spec = abs(spec);

subplot(321); imagesc(1-spec); title('1. STFT'); colormap jet;

spec = spec/(max(spec(:)));

spec = spec(6:233,:);

cMedian = median(spec,1);
rMedian = median(spec,2);

[R, C] = size(spec);

signal = zeros(size(spec));
noise = signal;

for i = 1 : R
    for j = 1 : C
        if spec(i,j)/3 >= cMedian(j) && spec(i,j)/3 >= rMedian(i)
            signal(i,j) = 1;
        else signal(i,j) = 0;
        end
        
        if spec(i,j)/2.5 >= cMedian(j) && spec(i,j)/2.5 >= rMedian(i)
            noise(i,j) = 1;
        else noise(i,j) = 0;
        end
    end
end

subplot(323); imagesc(1-signal); colormap gray; title('2. Selected pixels from spectrogram');

se = strel('rectangle', [4 4]);
signal = imerode(signal,se);
signal = imdilate(signal,se);

noise = imerode(noise,se);
noise = imdilate(noise,se);

subplot(325); imagesc(1-signal); colormap gray; title('3. Selected pixels after erosion & dilation');

signal = sum(signal,1) > 0;
noise = sum(noise,1) > 0;

se = strel('rectangle',[1 4]);
signal = imdilate(signal,se);
signal = imdilate(signal,se);
noise = imdilate(noise,se);
noise = imdilate(noise,se);

x = 1 : wLength * 0.25 : length(signal) * wLength * 0.25;
xq = 1 : length(signal) * wLength * 0.25;

signalS = [interp1(x,double(signal),xq) zeros(1,length(v) - length(xq))];
noiseS = [interp1(x,double(noise),xq) zeros(1,length(v) - length(xq))];

signalS = v(signalS' == 1);
noiseS = v(noiseS' == 0);

audiowrite('testSignal.wav', signalS, Fs);
audiowrite('testNoise.wav', noiseS, Fs);

subplot(324); imagesc(1-signal); title('5. hasBird');
subplot(326); imagesc(noise); title('6. noBird'); colormap gray;
subplot(322); plot(v, 'black'); title('4. Original recording'); axis tight;