#!/usr/bin/env python3

import functools
import operator
import sys


def set_size(new_size: int):
    global size
    size = new_size  # bits in the lfsr: 0 to size - 1
    global lfsr_length_mask
    lfsr_length_mask = functools.reduce(operator.ior, [(1 << i) for i in range(size)])  # the bit mask to cut the number to the length of the shift register after shifting to the left
    global taps
    taps = [size - 1, 0]  # a list of XOR taps


def lfsr(init_value: int):
    value = init_value & lfsr_length_mask
    while True:
        yield value
        bit = functools.reduce(operator.ixor, [(value >> i) for i in taps]) & 1  # calculate the new inserted bit by performing an XOR operation of all the bits at the tap positions
        value = ((value << 1) | bit) & lfsr_length_mask


def rotation_length(init_value: int):
    init_value = init_value & lfsr_length_mask
    first_value = True
    num_cycles = 0
    for i in lfsr(init_value):
        # print(i)
        if i == init_value and (not first_value):
            break
        first_value = False  # after first iteration this is not the first value any more
        num_cycles += 1
    # print(f"Number of cycles: {num_cycles}")
    return num_cycles - 1


def find_ideal_start_values(length: int):
    rotation_lengths = []
    set_size(length)
    for i in range(2**size):
        rotation_lengths.append(rotation_length(i))
    PrintDictAsTable({num: rotation_lengths[num] for num in range(len(rotation_lengths))}, "start value", "# numbers till rotation")
    print(f"Maximum rotation length: {max(rotation_lengths)}")


def PrintDictAsTable(dataset: dict, title_keys: str, title_values: str):
    # get the max length of a string in the key and in the value section
    max_key_len, max_value_len = len(title_keys), len(title_values)
    for (i, j) in zip([*dataset.keys()], [*dataset.values()]):
        max_key_len = max(len(str(i)), max_key_len)
        max_value_len = max(len(str(j)), max_value_len)

    print("┌─" + "─" * max_key_len + "─┬─" + "─" * max_value_len + "─┐")
    print("│ " + title_keys + " " * (max_key_len - len(title_keys)) + " │ " + title_values + " " * (max_value_len - len(title_values)) + " │")
    print("├─" + "─" * max_key_len + "─┼─" + "─" * max_value_len + "─┤")
    for (i, j) in zip([*dataset.keys()], [*dataset.values()]):
        print("│ " + str(i) + " " * (max_key_len - len(str(i))) + " │ " + str(j) + " " * (max_value_len - len(str(j))) + " │")
    print("└─" + "─" * max_key_len + "─┴─" + "─" * max_value_len + "─┘")


if __name__ == "__main__":
    find_ideal_start_values(int(sys.argv[1]))
