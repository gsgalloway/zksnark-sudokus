fn find_factors(x: u128) {
    return find_factors_recursive(x, 2);
}

fn find_factors_recursive(x: u128, i: u128) {
    if (i > x / 2) {
        panic_with_felt252('not a composite number');
    }
    if (x % i == 0) {
        return ();
    }
    return find_factors_recursive(x, i+1);
}

#[test]
#[available_gas(100000)]
fn test_find_factors() {
    find_factors(10);
}
