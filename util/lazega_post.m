function attr = lazega_post(ELattr)
% lazega_post: we post conduct the attributes value and set it in an acceptable form
% Elattr: the attributes' value
attr = zeros(size(ELattr, 1), 100);
col_count = 0;

% Column 2 is the status: 1 = partner; 2 = associate
% We set 1 = partner and 0 = associate
col_count = col_count + 1;
attr_1 = ELattr(:, 2);
attr_1(attr_1 == 2) = 0;
attr(:, 1) = attr_1;

% Column 3 is the gender: 1 = man; 2 = woman
% We set 1 = man and 0 = woman
col_count = col_count + 1;
attr_1 = ELattr(:, 3);
attr_1(attr_1 == 2) = 0;
attr(:, 2) = attr_1;

% Column 4 is the office (1=Boston; 2=Hartford; 3=Providence)
% We set (1, 0) = Boston, (0, 1) = Hartford, (0, 0) = Providence
col_count = col_count + 2;
attr_1 = ELattr(:, 4);
attr_1(attr_1~=1) = 0;
attr(:, 3) = attr_1;
attr_1 = ELattr(:, 4);
attr_1(attr_1~=2) = 0;
attr_1(attr_1 == 2) = 1;
attr(:, 4) = attr_1;

% Column 5 is the years with the firm
% We set (1, 0) ==  [0, 5] years, (0, 1) == (5, 20], (0, 0) = (20, \infty) :)
col_count = col_count + 2;
attr_1 = ELattr(:, 5);
attr_1(attr_1 <= 5) = 1;
attr_1(attr_1 > 5) = 0;
attr(:, 5) = attr_1;
attr_1 = ELattr(:, 5);
attr_1(attr_1 > 20) = 0;
attr_1(attr_1 <= 5) = 0;
attr_1((attr_1>5)&(attr_1<=20)) = 1;
attr(:, 6) = attr_1;

% Column 6 is the age
% We set (1, 0) ==  [0, 35] years, (0, 1) == (35, 50], (0, 0) = (50, \infty) :)
col_count = col_count + 2;
attr_1 = ELattr(:, 6);
attr_1(attr_1 <= 35) = 1;
attr_1(attr_1 > 35) = 0;
attr(:, 7) = attr_1;
attr_1 = ELattr(:, 6);
attr_1(attr_1 > 50) = 0;
attr_1(attr_1 <= 35) = 0;
attr_1((attr_1>35)&(attr_1<=50)) = 1;
attr(:, 8) = attr_1;

% Column 7 is the practice: 1=litigation; 2=corporate
% We set 1 = litigation and 0 = corporate
col_count = col_count + 1;
attr_1 = ELattr(:, 7);
attr_1(attr_1 == 2) = 0;
attr(:, 9) = attr_1;

% Column 8 is the law school: 1 = Harvard, Yale; 2 = ucon; 3 = other)
% We set (1, 0) = Harvard, Yale, (0, 1) = ucon, (0, 0) = other
col_count = col_count + 2;
attr_1 = ELattr(:, 8);
attr_1(attr_1~=1) = 0;
attr(:, 10) = attr_1;
attr_1 = ELattr(:, 8);
attr_1(attr_1~=2) = 0;
attr_1(attr_1 == 2) = 1;
attr(:, 11) = attr_1;

attr = attr(:, 1:col_count);
end

