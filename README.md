# Avito ProfTask

## Описание проекта

Это приложение позволяет просматривать и сортировать фотографии, полученные из API Unsplash. Функционал включает в себя:

1. **Фильтрация элементов**: 
    - Элементы не отображаются на экране, если сервер не предоставил всю необходимую информацию для их корректного отображения.
    - Например, фотографии без описания не показываются в списке.

2. **Режимы отображения списка**:
    - Присутствует кнопка **Switch Mode**, которая переключает между различными режимами отображения фотографий: сеточный режим и режим одной колонки.
    - Фотографии без описания не отображаются в любом режиме.

3. **Представление элементов**:
    - В списке отображается **превью фотографии** и **дата создания** фотографии.

4. **Детальная информация**:
    - При переходе на детальный экран, можно увидеть имя автора фотографии, а также (опционально) ссылки на его **портфолио** и **Instagram**.
  
5. **Пагинация**:
    - Реализована пагинация для удобного перехода между страницами с фотографиями.
    - **Известная проблема**: После перехода на другую страницу текущий фильтр сбрасывается (эта часть требует доработки).

6. **Сортировка**:
    - По умолчанию фотографии сортируются по **релевантности**. Можно изменить сортировку на **последние**.

7. **Известные проблемы**:
    - Есть небольшой **конфликт констрейнтов** при переключении между режимами отображения списка (временное решение: визуальные баги минимальны и не влияют на функционал).
  
8. **Функции в детальном экране**:
    - На экране деталей фотографии реализованы функции **сохранения** фотографии на устройство и **поделиться** фотографией.
