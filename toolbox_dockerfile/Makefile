PHONY: image push release clean

TAG=vancluever/dacd_reference_toolbox

image:
	docker build --tag $(TAG):latest .

push: image
	docker push $(TAG):latest

release: push

clean:
	docker rmi -f $(TAG)
