"""Load html from files, clean up, split, ingest into Weaviate."""
import pickle
import time

from langchain.document_loaders import DirectoryLoader
from langchain.embeddings import VertexAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.vectorstores.faiss import FAISS


def ingest_docs():
    """Get documents from web pages."""
    start = time.time()
    loader = DirectoryLoader("./ingested/", show_progress=True)
    print('Loading docs...', time.time() - start)
    raw_documents = loader.load()
    print('Loaded raw docs...', time.time() - start)
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=200,
    )
    print('Splitting docs...', time.time() - start)
    documents = text_splitter.split_documents(raw_documents)
    embeddings = VertexAIEmbeddings()
    print('Calling vector store...', time.time() - start)
    vectorstore = FAISS.from_documents(documents, embeddings)

    # Save vectorstore
    print('Storing vector store with embeddings...', time.time() - start)
    vectorstore.save_local('./vecstoredir/')
    print('Finished.', time.time() - start)


if __name__ == "__main__":
    ingest_docs()
