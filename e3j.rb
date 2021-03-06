def e3j(lines)
	result = ""
	i = 0
	while i < lines.size
		line = lines[i]
		words = line.strip.split(/\s+/)
		if words[0] == "print"
			result += "System.out.println(" + words[1..-1].join(" ") + ");"
		elsif words[0] == "negate"
			result += words[1] + "=!" + words[1] + ";"
		elsif words[0] == "increment"
			result += words[1] + "++;"
		elsif words[0] == "decrement"
			result += words[1] + "--;"
		elsif words[0..1] == ["input", "string"]
			result += "String " + words[2] + "=new java.util.Scanner(System.in).nextLine();"
		elsif words[0..1] == ["input", "number"]
			result += "int " + words[2] + "=new java.util.Scanner(System.in).nextInt();"
		elsif [words[0], words[2]] == ["define", "as"]
			value = words[3..-1].join(" ")
			result += getType(value) + " " + words[1] + "=" + value + ";"
		elsif [words[0], words[2]] == ["set", "to"]
			result += words[1] + "=" + words[3..-1].join(" ") + ";"
		elsif [words[0], words[2]] == ["add", "to"]
			result += words[3] + "+=" + words[1] + ";"
		elsif [words[0], words[2]] == ["subtract", "from"]
			result += words[3] + "-=" + words[1] + ";"
		elsif [words[0], words[2]] == ["multiply", "by"]
			result += words[1] + "*=" + words[3] + ";"
		elsif [words[0], words[2]] == ["divide", "by"]
			result += words[1] + "/=" + words[3] + ";"
		elsif words[0] == "if"
			ending = blockEnd(lines, i)
			result += "if(" + condition(words[1..-1]) + "){\n" + e3j(lines[i + 1...ending]) + "}"
			i = ending - 1
		elsif words[0] == "unless"
			ending = blockEnd(lines, i)
			result += "if(!(" + condition(words[1..-1]) + ")){\n" + e3j(lines[i + 1...ending]) + "}"
			i = ending - 1
		elsif words[0] == "while"
			ending = blockEnd(lines, i)
			result += "while(" + condition(words[1..-1]) + "){\n" + e3j(lines[i + 1...ending]) + "}"
			i = ending - 1
		elsif words[0] == "until"
			ending = blockEnd(lines, i)
			result += "while(!(" + condition(words[1..-1]) + ")){\n" + e3j(lines[i + 1...ending]) + "}"
			i = ending - 1
		elsif words == ["otherwise"]
			ending = blockEnd(lines, i)
			result += "else{\n" + e3j(lines[i + 1...ending]) + "}"
			i = ending - 1
		elsif words[0..1] == ["otherwise", "if"]
			ending = blockEnd(lines, i)
			result += "else if(" + condition(words[2..-1]) + "){\n" + e3j(lines[i + 1...ending]) + "}"
			i = ending - 1
		else
			abort "error on the following line:\n" + line
		end
		i += 1
		result += "\n"
	end
	return result
end

def getType(str)
	return "String" if str.index "\""
	return "boolean" if ["true", "false"].index str
	return "int"
end

def blockEnd(lines, index)
	indents = lines[index].chars.index {|c| c != "\t"}
	index += 1
	while index < lines.size
		return index if lines[index].chars.index {|c| c != "\t"} <= indents
		index += 1
	end
	return lines.size
end

def condition(words)
	if words.size == 1
		return words[0]
	elsif words.index {|word| /^(and|or)$/ =~ word}
		index = words.index {|word| /^(and|or)$/ =~ word}
		return condition(words[0...index]) + (words[index] == "and" ? "&&" : "||") + condition(words[index + 1..-1])
	elsif words[1] == "equals"
		return "equal(" + words[0] + "," + words[2] + ")"
	elsif words[1..3] == ["is", "less", "than"]
		return words[0] + "<" + words[4]
	elsif words[1..3] == ["is", "greater", "than"]
		return words[0] + ">" + words[4]
	elsif words[1] == "divides"
		return words[2] + "%" + words[0] + "==0"
	else
		abort "error on the following condition:\n" + words.join(" ")
	end
end

input = ARGV[0]
output = ARGV[1]

File.write("#{output}.java", "public class #{output}{
public static boolean equal(int x, int y) {return x==y;}
public static boolean equal(String x, String y) {return x.equals(y);}
public static boolean equal(boolean x, boolean y) {return x==y;}
public static void main(String[] $){
" + e3j(File.read(input).downcase.split($/).map(&:rstrip).select {|line| line.size > 0}) + "}}")