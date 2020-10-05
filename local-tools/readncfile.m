
% To use this script, you must set infn to equal the filename including the
% path
A=ncinfo(infn);

for ll=1:length(A.Variables(:))
eval([A.Variables(ll).Name,'=ncread(infn,A.Variables(ll).Name);']);
end

for kk=1:length(A.Groups(:))
  for ll=1:length(A.Groups.Variables(:))
    slash='/';
    eval([A.Groups(kk).Variables(ll).Name,'=ncread(infn,[A.Groups(kk).Name,slash,A.Groups(kk).Variables(ll).Name]);']);
    clear slash;
  end
end

clear kk ll;