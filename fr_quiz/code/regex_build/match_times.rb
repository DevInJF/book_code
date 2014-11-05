#!/usr/local/bin/ruby
#---
# Excerpted from "Best of Ruby Quiz"
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_quiz for more book information.
#---
require "benchmark"

Benchmark.bm(16) do |stats|
  { "Mark Hubbart"   => "grouped",
    "Thomas Leitner" => "fast",
    "Tanaka Akira"   => "limited" }.each do |name, library|
    require library
    regex = Regexp.build(1..5_000)
    stats.report(name) do
      50_000.times { "4098" =~ regex }
    end
  end
end