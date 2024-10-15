def firstRepeat(string):
    words = string.split()

    def doer(remaining,seen):
        if remaining_words == 0:
            return None
        
        current_word = remaining words[0]
        
        if current_word in seen:
            return current_word
        
        seen.add(current_word)

        return doer(remaining[1:],seen)
    return doer(words,set())