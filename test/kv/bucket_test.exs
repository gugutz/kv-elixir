defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    # the start_link bellow is just to illustrate that is also possible
    # i should always use start_supervised!/1 function to start processes for ExUnit to test cases since it shuts down the process before each test
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  
  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "deletes a value using a key", %{bucket: bucket} do
    key = "fruits"
    KV.Bucket.put(bucket, key, 3)
    assert KV.Bucket.get(bucket, key) == 3
    KV.Bucket.delete(bucket, key)
    assert KV.Bucket.get(bucket, key) == nil
  end
  
end

