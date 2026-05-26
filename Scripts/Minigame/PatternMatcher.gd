class_name PatternMatcher
extends RefCounted

static func check(input: String, pattern: String) -> bool:
	return input.strip_edges() == pattern.strip_edges()
