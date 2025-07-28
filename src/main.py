try:
    import pyconcrete
except:
    pass
import uvicorn
from fastapi import FastAPI
from pydantic import BaseModel

from tool.tt import add_two

app = FastAPI()


class Item(BaseModel):
    a: int | None = 1
    b: int | None = 2


@app.post('/add')
def add_item(item: Item):
    return add_two(item.a, item.b)


if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000)
