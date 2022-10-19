﻿
#Область ОбработчикиСобытийФормы 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ТипЦеныЗакупочная = ПланыВидовХарактеристик.гф_ГлобальныеЗначения.НайтиПоРеквизиту(
								"Ключ", "гф_ГлобальныеЗначенияОптоваяЗакупочнаяЦена").Значение;
	
КонецПроцедуры 

&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	Диалог.Заголовок = "Выберите файл загрузки";
	Диалог.Фильтр = "Файлы Excel (*.xls, *.xlsx)|*.xl*";
	Диалог.ПолноеИмяФайла = ""; 	 
    Диалог.МножественныйВыбор = Ложь;
	
	Если Диалог.Выбрать() Тогда
		ПутьКФайлу = Диалог.ПолноеИмяФайла;
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ЗаполнитьЗаказКлиента(Команда)
	
	ВладелецФормы.Объект.гф_ТоварыВКоробах.Очистить();
	Форма = ЭтотОбъект;
	Для каждого Строка Из ДанныеФайла Цикл
		
		НоваяСтрока = ВладелецФормы.Объект.гф_ТоварыВКоробах.Добавить();
		НоваяСтрока.ВариантКомплектации = Строка.ВариантКомплектации;
		НоваяСтрока.Количество = Строка.Количество;  
		НоваяСтрока.ЦенаКороба = Строка.Цена;
		НоваяСтрока.Сумма = Строка.Сумма; 
		
	КонецЦикла;
	
	ВладелецФормы.Модифицированность = Истина;
	Форма.Закрыть();
	
КонецПроцедуры

&НаСервере
Функция ПолучитьЦенуНоменклатуры(Номенклатура, Характеристика)
	
	Отбор = Новый Структура;
	Отбор.Вставить("Номенклатура", Номенклатура);	
	Отбор.Вставить("ВидЦены", ТипЦеныЗакупочная);
	
	Возврат РегистрыСведений.ЦеныНоменклатуры25.ПолучитьПоследнее(ТекущаяДатаСеанса(), Отбор).Цена;
	
КонецФункции

&НаСервере
Функция НайтиХарактеристикуНоменклатуры(Номенклатура, НаименованиеХарактеристики)
	
	Если Номенклатура.ИспользованиеХарактеристик = 
		Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеДляВидаНоменклатуры  Тогда
		Владелец = Номенклатура.ВидНоменклатуры;
		
	ИначеЕсли  Номенклатура.ИспользованиеХарактеристик = 
		Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.ОбщиеСДругимВидомНоменклатуры Тогда
		
		Владелец = Номенклатура.ВладелецХарактеристик;
	Иначе	
		Владелец = Номенклатура;
	КонецЕсли;	
	
	Возврат Справочники.ХарактеристикиНоменклатуры.НайтиПоНаименованию(НаименованиеХарактеристики, Истина, ,
																		Владелец);	
	
КонецФункции	

&НаСервере
Функция ПолучитьОсновнойВариантКомплектации(Номенклатура, Характеристика)
			
	Запрос = Новый Запрос(
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Таблица.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ВариантыКомплектацииНоменклатуры КАК Таблица
	|ГДЕ
	|	Таблица.Владелец = &Номенклатура
	|	И Таблица.Характеристика = &Характеристика
	|   И Таблица.ПометкаУдаления = Ложь
	|");
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	Запрос.УстановитьПараметр("Характеристика", Характеристика);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда
		Результат = Выборка.Ссылка;
	Иначе
		Результат = Неопределено;
	КонецЕсли;

	Возврат Результат;
	
КонецФункции

&НаСервере
Функция НоменклатураПоАртикулу(Артикул) 
	
	Отбор = Новый Структура;
	Отбор.Вставить("ЧистыйАртикул", Артикул);
	НайденныеСтроки = ТаблицаНоменклатуры.НайтиСтроки(Отбор);
	
	Если НайденныеСтроки.Количество() <> 0 Тогда
		 Возврат НайденныеСтроки[0].Номенклатура;
	 Иначе
		 Возврат Справочники.Номенклатура.ПустаяСсылка();
	КонецЕсли;	
		
КонецФункции	

&НаКлиенте
Процедура ПрочитатьФайл(Команда)
	
	ДанныеФайла.Очистить();
	ТекстОшибки = "";
	НомерКолонкиС  = НомерКолонкиЕксельПоИмени(ВРег(ЗагружатьС));
	НомерКолонкиПо = НомерКолонкиЕксельПоИмени(ВРег(ЗагружатьПо));
		
	Если Не ЗначениеЗаполнено(НомерКолонкиС) 
		Или Не ЗначениеЗаполнено(НомерКолонкиПо) Тогда
		СообщитьПользователю("Неверный формат имен колонок строки ростовки.");
		Возврат;
	КонецЕсли;	
	
	Попытка 
		ex = ПолучитьCOMобъект("", "Excel.Application");
	Исключение
		СообщитьПользователю("Excel Application не создан!!");
		Возврат;
	КонецПопытки;
	
	Попытка
		ex.workbooks.open(ПутьКФайлу, 1);
	Исключение
		СообщитьПользователю("Файл перемещен или удален!");
		Возврат;
	КонецПопытки; 
	
	ПолучитьТаблицуНоменклатуры();	
	
	СоответствиеКолонок = Новый Соответствие;
	СформироватьСоответствиеКолонок(СоответствиеКолонок, ex, ТекстОшибки, 
									НомерКолонкиС, НомерКолонкиПо);
	
	Если ТекстОшибки <> "" Тогда
		СообщитьПользователю(ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	ЗагрузитьДанныеИзФайла(ex, СоответствиеКолонок, НомерКолонкиС, НомерКолонкиПо);
		
	ex.workbooks.Close();
	ex.quit();

КонецПроцедуры  

&НаКлиенте
Процедура СформироватьСоответствиеКолонок(СоответствиеКолонок, ex, ТекстОшибки, 
											НомерКолонкиС, НомерКолонкиПо)
	
	Для Колонка = НомерКолонкиС По НомерКолонкиПо Цикл
		
		_ИмяКолонки = ex.ActiveSheet.Cells(СтрокаНаименованияРостовки, Колонка).Value;
		Размер = Лев(СокрЛП(_ИмяКолонки), 3);
		
		РазмерЧислом = ПреобразоватьВЧисло(Размер);
		
		Если РазмерЧислом = 0 Тогда 
			
			ТекстОшибки = ТекстОшибки + ("Наименование колонки " + _ИмяКолонки 
							+ " строки наименования ростовки не соответствует формату. Номер колонки XSL " 
							+ Колонка);
			Возврат;

		КонецЕсли;	
				
		СоответствиеКолонок.Вставить(Колонка, Размер);
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьДанныеИзФайла(ex, СоответствиеКолонок, НомерКолонкиС, НомерКолонкиПо)

	RCount = ex.ActiveSheet.UsedRange.Rows.Count();
	
	Для j = СтрокаЗагрузки По RCount Цикл
			
		_Артикул = ex.ActiveSheet.Cells(j, КолонкаАртикул).Text;
		Артикул = УбратьЛишниеСимволы(_Артикул);
		Номенклатура = НоменклатураПоАртикулу(СокрЛП(Артикул));
		
		Если ЗначениеЗаполнено(Номенклатура) Тогда			
			
			ОбработатьКолонкиРостовки(ex, j, Номенклатура, СоответствиеКолонок,  НомерКолонкиС, НомерКолонкиПо);
				
		Иначе
			СообщитьПользователю("Не найдена номенклатура с артикулом " + Артикул + " в строке " + Строка(j));
			Продолжить;
		КонецЕсли;
	КонецЦикла;	

	
КонецПроцедуры

&НаКлиенте 
Процедура ОбработатьКолонкиРостовки(ex, j, Номенклатура, СоответствиеКолонок, НомерКолонкиС, НомерКолонкиПо)
	
	Для Колонка = НомерКолонкиС По НомерКолонкиПо Цикл 
		
		_Количество = ex.ActiveSheet.Cells(j, Колонка).Value;
		
		Если ЗначениеЗаполнено(_Количество) Тогда
			
			Количество = ПреобразоватьВЧисло(_Количество);
			
			Если Количество = 0 И _Количество <> "0" Тогда
				СообщитьПользователю("Ошибка преобразования в число. Данные по строке XSL " + Строка(j) 
				+ "файла XSL не загружены.");
				Продолжить;	
			КонецЕсли;	
			
			Размер = СоответствиеКолонок.Получить(Колонка);
			
			Характеристика = НайтиХарактеристикуНоменклатуры(Номенклатура, Размер);
			
			Если Не ЗначениеЗаполнено(Характеристика) Тогда 
				СообщитьПользователю("Не найдена характеристика для размера " + Размер);
				Продолжить;
			КонецЕсли;	
			
			ВариантКомплектации = ПолучитьОсновнойВариантКомплектации(Номенклатура, Характеристика);
			
			Если ВариантКомплектации = Неопределено Тогда
				СообщитьПользователю("Не найден вариант комплектации для номенклатуры " 
				+ Строка(Номенклатура) + " с характеристикой " 
				+ Строка(Характеристика) + ". Данные по строке XSL " 
				+ Строка(j) + "файла XSL не загружены.");
				Продолжить;
			КонецЕсли;	
			
			НоваяСтрока = ДанныеФайла.Добавить();
			
			НоваяСтрока.ВариантКомплектации = ВариантКомплектации;
			НоваяСтрока.Количество = Число(Количество);
			НоваяСтрока.Цена = ПолучитьЦенуНоменклатуры(Номенклатура, Характеристика);  
			НоваяСтрока.Сумма = НоваяСтрока.Количество * НоваяСтрока.Цена;
			
		КонецЕсли;	
		
	КонецЦикла;  
	
КонецПроцедуры

&НаКлиенте 
Функция ПреобразоватьВЧисло(ЧислоСтрокой)
	
	ОписаниеТипаЧисла = Новый ОписаниеТипов("Число");
	ЗначениеЧисла = ОписаниеТипаЧисла.ПривестиЗначение(ЧислоСтрокой);
	
	Возврат ЗначениеЧисла;
	
КонецФункции

&НаКлиенте
Функция НомерКолонкиЕксельПоИмени(тИмяКолонки)
  тЛатАлфавит = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  тДлинаНомера = СтрДлина(тИмяКолонки);
 
   тНомерКолонки = 0;
 
   Для тСчет = 1 По тДлинаНомера Цикл
      тПоз = СтрНайти(тЛатАлфавит, Сред(тИмяКолонки, (тДлинаНомера + 1 - тСчет), 1));
      тНомерКолонки = тНомерКолонки + тПоз * Pow(26, тСчет - 1);
   КонецЦикла;
 
   Возврат тНомерКолонки;
КонецФункции

&НаКлиенте
Процедура СообщитьПользователю(Текст)
	
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = Текст;
	Сообщение.Сообщить();
	
КонецПроцедуры	

&НаСервере
Процедура ПолучитьТаблицуНоменклатуры() 
	
	ТаблицаНоменклатуры.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Номенклатура,
	|	Номенклатура.Артикул КАК Артикул,
	|	"""" КАК ЧистыйАртикул
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.ПометкаУдаления = ЛОЖЬ
	|	И Номенклатура.Артикул <> """"";
	
	Таблица = Запрос.Выполнить().Выгрузить();
	
	Для каждого Строка Из Таблица Цикл
		НоваяСтрока = ТаблицаНоменклатуры.Добавить();
		НоваяСтрока.Номенклатура = Строка.Номенклатура;
		НоваяСтрока.ЧистыйАртикул = УбратьЛишниеСимволы(Строка.Артикул);		
	КонецЦикла;	
		
КонецПроцедуры	

&НаСервере
Функция УбратьЛишниеСимволы(мСтрока) 
	
	НовСтрока = "";
	
	ПравильныеСимволы = "1234567890";
	
	Для Сч = 1 По СтрДлина(мСтрока) Цикл       
		
		ТекСимвол = Сред(мСтрока, Сч, 1);        
		
		Если СтрНайти(ПравильныеСимволы, ТекСимвол) > 0 Тогда
			
			НовСтрока = НовСтрока + ТекСимвол;
			
		КонецЕсли;                        
	КонецЦикла;
	
	Возврат НовСтрока;
	
КонецФункции 

#КонецОбласти
