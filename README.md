# A Beam QA Bot!

This is an experiment by @pabloem on building a simple chatbot for answering Beam questions. My effort so far is not very successful.

This chatbot works using Langchain, an toolkit for generative AI. The chatbot works in the following way:

1. Receive a prompt from the user
2. Convert the prompt into a Vector, using VertexAI's Text Embedding API
3. Use the prompt's Vector to look up **documents** from a database of Beam-related documents
4. Pass the user prompt along with the documents that we found as context to the Vertex AI PaLM API for text generation
5. Return the result to the user.

The database with Beam-related documents was built using the scripts
`ingest.sh`, `ingest_so.sh` and `ingest.py`, and stored in cloud storage under
`gs://apache-beam-testing-pabloem/beam-qa/vecstore/vecstoredir`.

## Installing dependencies

To run this chatbot, you can install its dependencies in a virtualenv:

```sh
virtualenv venv
. venv/bin/activate

pip install -r requirements.txt
```

## Running with prebuilt artifacts

You can easily run the QA bot without building your own document database, just download the existing one:

```sh
gsutil cp -r gs://apache-beam-testing-pabloem/beam-qa/vecstore/vecstoredir .
```

Once you have the document database, you can run the chatbot:

```sh
make start
```

## Building your own Beam document database

To build your own document database, please inspect all of the `ingest*` files in this repository.
In short, the steps I followed were:
- Download every document under https://beam.apache.org (by running `ingest.sh`)
- Download every StackOverflow question with the `apache-beam` tag. (by running `ingest_so.sh`)
- Run `python ingest.py`

**Likely improvements** are:
- Ensure that the StackOverflow documents are cleaner than they are right now.
- Use a wider set of Beam docs (perhaps Dataflow support examples?)
- Use a PaLM 2 model instead of the current default of PaLM.
- Use a HuggingFace model, or GPT 4 instead of the current model.

------------------------

**The text below is from the original repository**

# 🦜️🔗 ChatLangChain

This repo is an implementation of a locally hosted chatbot specifically focused on question answering over the [LangChain documentation](https://langchain.readthedocs.io/en/latest/).
Built with [LangChain](https://github.com/hwchase17/langchain/) and [FastAPI](https://fastapi.tiangolo.com/).

The app leverages LangChain's streaming support and async API to update the page in real time for multiple users.

## ✅ Running locally
1. Install dependencies: `pip install -r requirements.txt`
1. Run `ingest.sh` to ingest LangChain docs data into the vectorstore (only needs to be done once).
   1. You can use other [Document Loaders](https://langchain.readthedocs.io/en/latest/modules/document_loaders.html) to load your own data into the vectorstore.
1. Run the app: `make start`
   1. To enable tracing, make sure `langchain-server` is running locally and pass `tracing=True` to `get_chain` in `main.py`. You can find more documentation [here](https://langchain.readthedocs.io/en/latest/tracing.html).
1. Open [localhost:9000](http://localhost:9000) in your browser.

## 🚀 Important Links

Deployed version (to be updated soon): [chat.langchain.dev](https://chat.langchain.dev)

Hugging Face Space (to be updated soon): [huggingface.co/spaces/hwchase17/chat-langchain](https://huggingface.co/spaces/hwchase17/chat-langchain)

Blog Posts: 
* [Initial Launch](https://blog.langchain.dev/langchain-chat/)
* [Streaming Support](https://blog.langchain.dev/streaming-support-in-langchain/)

## 📚 Technical description

There are two components: ingestion and question-answering.

Ingestion has the following steps:

1. Pull html from documentation site
2. Load html with LangChain's [ReadTheDocs Loader](https://langchain.readthedocs.io/en/latest/modules/document_loaders/examples/readthedocs_documentation.html)
3. Split documents with LangChain's [TextSplitter](https://langchain.readthedocs.io/en/latest/reference/modules/text_splitter.html)
4. Create a vectorstore of embeddings, using LangChain's [vectorstore wrapper](https://python.langchain.com/en/latest/modules/indexes/vectorstores.html) (with OpenAI's embeddings and FAISS vectorstore).

Question-Answering has the following steps, all handled by [ChatVectorDBChain](https://langchain.readthedocs.io/en/latest/modules/indexes/chain_examples/chat_vector_db.html):

1. Given the chat history and new user input, determine what a standalone question would be (using GPT-3).
2. Given that standalone question, look up relevant documents from the vectorstore.
3. Pass the standalone question and relevant documents to GPT-3 to generate a final answer.
