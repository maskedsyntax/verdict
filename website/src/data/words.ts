import answersText from '../../../assets/words/answers.txt?raw'
import validWordsText from '../../../assets/words/valid_words.txt?raw'

const parseWordList = (source: string) => source.trim().split(/\s+/)

export const answers = parseWordList(answersText)
export const validWords = new Set([...parseWordList(validWordsText), ...answers])
