shared_examples_for 'defer to unique index' do
  it "should defer to unique index" do
    expect {
      subject.save
    }.to raise_error(ActiveRecord::RecordNotUnique, /duplicate key value violates unique constraint/)
  end
end