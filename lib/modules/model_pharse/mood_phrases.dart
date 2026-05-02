import 'dart:math';

final Map<String, List<String>> moodPhrases = {
  'happy': [
    'I love you!',
    'The cat wants to kiss you!',
    'You are my favorite human!',
    'Life is good!',
    'I am so happy you are here!',
    'Best day ever!',
    'I feel amazing today!',
    'Snuggles please!',
    'Everything is purr-fect!',
    'I just want to be near you!',
    'You make my tail wag!',
    'I\'m so glad you\'re home!',
    'Happy happy happy!',
    'Let\'s cuddle on the couch!',
    'You are the best owner in the world!',
  ],
  'hungry': [
    'Feed me now!',
    'Food time!',
    'My bowl is empty...',
    'I could eat a whole fish right now.',
    'Is it dinner time yet?',
    'I\'m starving!',
    'Give me a treat, please!',
    'I smell food!',
    'Can I have some of what you\'re eating?',
    'More kibble, please!',
    'I need a snack immediately!',
    'My tummy is rumbling...',
    'Where are the treats hidden?',
    'I promise I haven\'t eaten all day!',
    'Just one small bite?',
  ],
  'playful': [
    'Let\'s play!',
    'Geo geoo fun!',
    'Throw the ball!',
    'Catch me if you can!',
    'Zoomies time!',
    'Where is my favorite toy?',
    'Chase me!',
    'I have so much energy!',
    'Look what I found!',
    'Let\'s run around the house!',
    'Tag, you\'re it!',
    'I want to wrestle!',
    'Did someone say "walk"?',
    'I am ready for an adventure!',
    'Play with me, right now!',
  ],
  'angry': [
    'Back off!',
    'I\'m mad!',
    'Don\'t touch me!',
    'Grrrr... stay away!',
    'I need some space.',
    'Leave me alone right now.',
    'I am not in the mood.',
    'That\'s my spot!',
    'Stop bothering me.',
    'I said no!',
    'Don\'t take my toy away.',
    'I am very annoyed.',
    'Hiss! Stay back!',
    'I am not playing around.',
    'You woke me up from my nap!',
  ],
  'sad': [
    'I missed you...',
    'Give me a hug?',
    'I feel a bit lonely.',
    'Where have you been?',
    'Please don\'t leave me again.',
    'I need some attention.',
    'Nobody wants to play with me.',
    'I\'m feeling down today.',
    'Can I sleep on your lap?',
    'I had a bad dream.',
    'Are you mad at me?',
    'I just want to be held.',
    'Everything is boring without you.',
    'Why did you go away?',
    'I need some comfort.',
  ],
};

String getRandomPhrase() {
  List<String> all = moodPhrases.values.expand((l) => l).toList();
  return all[Random().nextInt(all.length)];
}

String getPhraseFromMood(String mood) {
  List<String> phrases = moodPhrases[mood] ?? moodPhrases['happy']!;
  return phrases[Random().nextInt(phrases.length)];
}
