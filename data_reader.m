% read all data from file
fid = fopen('h1n1_inc.csv');
str = fread(fid)';
fclose(fid);
len = length(str);

% figure out where the quotes are
quotes = find(str=='"');
inquotes = zeros(1,len);
for ii = 1:length(quotes)/2
  inquotes(quotes(ii*2-1):quotes(ii*2))=1;
end

% figure out the delimiters
delimiters = find(str==','|str==10);

% chop data up into entries using delimiters, making sure those in quotes
% are not used.
data = cell(1,length(delimiters));
prevloc = 0;
kk = 0;
for ii = 1:length(delimiters)
  if ~inquotes(delimiters(ii))
    kk = kk + 1;
    data{kk} = char(str(prevloc+1:delimiters(ii)-1));
    prevloc = delimiters(ii);
  end
end
data(kk+1:end)=[];

% the columns
numcol = 16;
if rem(length(data),numcol)~=0, error('number of columns not numcol'); end
columns = data(1:numcol);
columns{numcol}(end)=[];
data = data(numcol+1:end);
numrow = length(data)/numcol;
data = reshape(data,[numcol,numrow])';

% process the numbers and dates
isnum=[1 0 0 0 0 1 0 1 1 1 0 0 0 0 0 1];
datecol = 4;
for cc = find(isnum)
  data2=cellfun(@(s)str2num(s),data(:,cc),'UniformOutput',false);
  ii = cellfun(@isempty,data2);
  eval([columns{cc} '=zeros(numrow,1);']);
  eval([columns{cc} '(~ii)=cell2num(data2(~ii));']);
end
for cc = find(~isnum)
  eval([columns{cc} '=data(:,cc);']);
end
daysince01012000 = zeros(numrow,1);
for rr = 1:numrow
  if length(date{rr})==0
    date{rr} = date{rr-1};
    daysince01012000(rr)=daysince01012000(rr-1);
  elseif date{rr}(end-2)=='/'
    daysince01012000(rr) = datenum(date{rr},2);
  else
    % i believe these two dates were entered wrongly
    if strcmp(date{rr},'5/4/2005')
      date{rr} = '5/4/2009';
    elseif strcmp(date{rr},'5/5/2005')
      date{rr} = '5/5/2009';
    end
    daysince01012000(rr) = datenum(date{rr}([1:end-4 end-1:end]),2);
  end
end

savestr = 'save h1n1_inc daysince01012000 numrow numcol ';
for cc = 1:numcol
  savestr = [savestr columns{cc} ' '];
end
eval(savestr)

[d i] = sort(daysince01012000);
c = confirmed(i);
plot(d(14:end)-d(14)+1,cumsum(c(14:end)),'linewidth',2);
xlabel('Days since 15/13/2009');
ylabel('Cumulative confirmed cases');