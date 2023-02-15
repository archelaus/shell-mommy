# Author: archelaus
# Inspiration: https://github.com/sudofox/shell-mommy

function __call_mommy --on-event fish_postexec
  set -g prev_status $status

  # SHELL_MOMMYS_LITTLE - what to call you~ (default: "girl")
  # SHELL_MOMMYS_PRONOUNS - what pronouns mommy will use for themself~ (default: "her")
  # SHELL_MOMMYS_ROLES - what role mommy will have~ (default "mommy")

  set -g COLORS_LIGHT_PINK '\e[38;5;217m'
  set -g COLORS_LIGHT_BLUE '\e[38;5;117m'
  set -g COLORS_FAINT '\e[2m'
  set -g COLORS_RESET '\e[0m'

  set -g DEF_WORDS_LITTLE "girl"
  set -g DEF_WORDS_PRONOUNS "her"
  set -g DEF_WORDS_ROLES "mommy"
  set -g DEF_MOMMY_COLOR "$COLORS_LIGHT_PINK"
  set -g DEF_ONLY_NEGATIVE "false"

  set -g NEGATIVE_RESPONSES \
    "do you need MOMMYS_ROLE's help~? ❤️" \
    "Don't give up, my love~ ❤️" \
    "Don't worry, MOMMYS_ROLE is here to help you~ ❤️" \
    "I believe in you, my sweet AFFECTIONATE_TERM~ ❤️" \
    "It's okay to make mistakes, my dear~ ❤️" \
    "just a little further, sweetie~ ❤️" \
    "Let's try again together, okay~? ❤️" \
    "MOMMYS_ROLE believes in you, and knows you can overcome this~ ❤️" \
    "MOMMYS_ROLE believes in you~ ❤️" \
    "MOMMYS_ROLE is always here for you, no matter what~ ❤️" \
    "MOMMYS_ROLE is here to help you through it~ ❤️" \
    "MOMMYS_ROLE is proud of you for trying, no matter what the outcome~ ❤️" \
    "MOMMYS_ROLE knows it's tough, but you can do it~ ❤️" \
    "MOMMYS_ROLE knows MOMMYS_PRONOUN little AFFECTIONATE_TERM can do better~ ❤️" \
    "MOMMYS_ROLE knows you can do it, even if it's tough~ ❤️" \
    "MOMMYS_ROLE knows you're feeling down, but you'll get through it~ ❤️" \
    "MOMMYS_ROLE knows you're trying your best~ ❤️" \
    "MOMMYS_ROLE loves you, and is here to support you~ ❤️" \
    "MOMMYS_ROLE still loves you no matter what~ ❤️" \
    "You're doing your best, and that's all that matters to MOMMYS_ROLE~ ❤️" \
    "MOMMYS_ROLE is always here to encourage you~ ❤️"

  set -g POSITIVE_RESPONSES \
    "*pets your head*" \
    "awe, what a good AFFECTIONATE_TERM~\nMOMMYS_ROLE knew you could do it~ ❤️" \
    "good AFFECTIONATE_TERM~\nMOMMYS_ROLE's so proud of you~ ❤️" \
    "Keep up the good work, my love~ ❤️" \
    "MOMMYS_ROLE is proud of the progress you've made~ ❤️" \
    "MOMMYS_ROLE is so grateful to have you as MOMMYS_PRONOUN little AFFECTIONATE_TERM~ ❤️" \
    "I'm so proud of you, my love~ ❤️" \
    "MOMMYS_ROLE is so proud of you~ ❤️" \
    "MOMMYS_ROLE loves seeing MOMMYS_PRONOUN little AFFECTIONATE_TERM succeed~ ❤️" \
    "MOMMYS_ROLE thinks MOMMYS_PRONOUN little AFFECTIONATE_TERM earned a big hug~ ❤️" \
    "that's a good AFFECTIONATE_TERM~ ❤️" \
    "you did an amazing job, my dear~ ❤️" \
    "you're such a smart cookie~ ❤️"

  # allow for overriding of default words (IF ANY SET)

  if test -n "$SHELL_MOMMYS_LITTLE"
    set DEF_WORDS_LITTLE "$SHELL_MOMMYS_LITTLE"
  end
  if test -n "$SHELL_MOMMYS_PRONOUNS"
    set DEF_WORDS_PRONOUNS "$SHELL_MOMMYS_PRONOUNS"
  end
  if test -n "$SHELL_MOMMYS_ROLES"
    set DEF_WORDS_ROLES "$SHELL_MOMMYS_ROLES"
  end
  if test -n "$SHELL_MOMMYS_COLOR"
    set DEF_MOMMY_COLOR "$SHELL_MOMMYS_COLOR"
  end
  # allow overriding to true
  if test "$SHELL_MOMMYS_ONLY_NEGATIVE" = "true"
    set DEF_ONLY_NEGATIVE "true"
  end
  # if the array is set for positive/negative responses, overwrite it
  if test -n "$SHELL_MOMMYS_POSITIVE_RESPONSES"
    set POSITIVE_RESPONSES "$SHELL_MOMMYS_POSITIVE_RESPONSES"
  end
  if test -n "$SHELL_MOMMYS_NEGATIVE_RESPONSES"
    set NEGATIVE_RESPONSES "$SHELL_MOMMYS_NEGATIVE_RESPONSES"
  end

  # split a string on forward slashes and return a random element
  function pick_word
   random choice (string split -n / $argv)
  end

  function pick_response # given a response type, pick an entry from the array

    if test $argv[1]  = "positive"
      set element (random choice $POSITIVE_RESPONSES)
    else if test $argv[1] = "negative"
      set element (random choice $NEGATIVE_RESPONSES)
    else
      echo "Invalid response type: $argv[1]"
      exit 1
    end

    # Return the selected response
    echo "$element"

  end

  function sub_terms # given a response, sub in the appropriate terms
    set -l response $argv
    # pick_word for each term
    set -l affectionate_term (pick_word $DEF_WORDS_LITTLE)
    set -l pronoun (pick_word $DEF_WORDS_PRONOUNS)
    set -l role (pick_word $DEF_WORDS_ROLES)
    # sub in the terms, store in variable
    set -l response (echo "$response" | string replace "AFFECTIONATE_TERM" "$affectionate_term")
    set -l response (echo "$response" | string replace "MOMMYS_PRONOUN" "$pronoun")
    set -l response (echo "$response" | string replace "MOMMYS_ROLE" "$role")
    # we have string literal newlines in the response, so we need to printf it out
    # print faint and colorcode
    echo -e "$DEF_MOMMY_COLOR$response$COLORS_RESET"
  end

  function success
    if test "$DEF_ONLY_NEGATIVE" = "true"
      return 0
    end
    # pick_response for the response type
    set -l response (pick_response "positive")
    sub_terms "$response" >&2
    return 0
  end

  function failure
    set -l response (pick_response "negative")
    sub_terms "$response" >&2
    return $prev_status
  end

  if test $prev_status -eq 0
    success
  else
    failure
  end
end
