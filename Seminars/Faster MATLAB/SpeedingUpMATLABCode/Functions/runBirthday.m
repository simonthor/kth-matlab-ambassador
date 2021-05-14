function prob = runBirthday(numTrials, groupSize)%#codegen
% RUNBIRTHDAY Runs a Monte Carlo simulation using the Birthday Paradox
% code
%    PROB = RUNBIRTHDAY(NUMTRIALS, GROUPSIZE) Calls the birthday code
%    NUMTRIALS times to see if any birthdays match in a group of size
%    GROUPSIZE.  The return value is the probability that a match will be
%    found.
%
%    Example:
%    p = runBirthday(1e5, 30)

matches = false(1, numTrials);
for trial = 1:numTrials
    % Run a simulation for a group
    matches(trial) = birthday(groupSize);
end

% Probability is the sum of matches divided by number of trials
count = 0;
for trial = 1:numTrials
    count = count + matches(trial);
end
prob = count / numTrials;


function match = birthday(groupSize)
% BIRTHDAY Simulates a single trial of the Birthday Paradox

% Match is false until a birthday match is found
match = false;

% Initialize list of taken birthdays
bdaylist = zeros(1, groupSize);

for person = 1:groupSize
    % Randomly select a birthdate for the individual (ignore leap years)
    birthdate = randi(365);

    % Check if someone else in the group shares the same birthday
    if any(birthdate == bdaylist)
        % A match is found, return from the function
        match = true;
        return;
    end

    % Add the birthdate to the list for the group
    bdaylist(person) = birthdate;
end