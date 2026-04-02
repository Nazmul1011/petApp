import 'dart:math';

final Map<String, List<String>> moodPhrases = {
  'happy': [
    'I love you!',
    'The cat wants to kiss you!',
    'You are my favorite human!',
    'Life is good!'
  ],
  'hungry': [
    'Feed me now!',
    'Food time!',
    'My bowl is empty...',
    'I could eat a whole fish right now.'
  ],
  'playful': [
    'Let\'s play!',
    'Geo geoo fun!',
    'Throw the ball!',
    'Catch me if you can!'
  ],
  'angry': [
    'Back off!',
    'I\'m mad!',
    'Don\'t touch me!',
    'Grrrr... stay away!'
  ],
  'sad': [
    'I missed you...',
    'Give me a hug?',
    'I feel a bit lonely.',
    'Where have you been?'
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
