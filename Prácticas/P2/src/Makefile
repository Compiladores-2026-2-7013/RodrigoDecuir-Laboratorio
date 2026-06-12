CXX?=g++
EXE=analyzer
CXXFLAGS= -Wno-deprecated-register -Wall -O0 -std=c++14

SRCS = main.cpp Parser.cpp Lexer.cpp
OBJS = $(SRCS:.cpp=.o)

all: $(EXE)

Lexer.cpp: lexer.ll
	flex $<

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(EXE): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f $(OBJS) $(EXE) Lexer.cpp
