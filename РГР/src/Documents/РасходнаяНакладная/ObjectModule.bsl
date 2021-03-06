
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.ОстаткиНоменклатуры.Очистить();
	Движения.ОстаткиНоменклатуры.Записать();
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	
	Движения.Продажи.Очистить();
	Движения.Продажи.Записать();
	Движения.Продажи.Записывать = Истина;
	
	МоментВремени = ?(Режим = РежимПроведенияДокумента.Оперативный, Неопределено, МоментВремени());
	
	МетодСписания = Метод(Отказ, МоментВремени);
	
	Запрос = Новый Запрос;	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Сумма) КАК Сумма
	|ПОМЕСТИТЬ ДокТЧ
	|ИЗ
	|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	|ГДЕ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДокТЧ.Номенклатура КАК Номенклатура,
	|	ДокТЧ.Количество КАК Количество,
	|	ДокТЧ.Сумма КАК Сумма,
	|	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.КоличествоОстаток, 0) КАК КолОст,
	|	ЕСТЬNULL(ОстаткиНоменклатурыОстатки.СуммаОстаток, 0) КАК СумОст,
	|	ОстаткиНоменклатурыОстатки.ДатаПроведения
	|ИЗ
	|	ДокТЧ КАК ДокТЧ
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ОстаткиНоменклатуры.Остатки(
	|				&МоментВремени,
	|				Номенклатура В
	|					(ВЫБРАТЬ
	|						ДокТЧ.Номенклатура
	|					ИЗ
	|						ДокТЧ КАК ДокТЧ)) КАК ОстаткиНоменклатурыОстатки
	|		ПО ДокТЧ.Номенклатура = ОстаткиНоменклатурыОстатки.Номенклатура
	|
	|УПОРЯДОЧИТЬ ПО
	|	ОстаткиНоменклатурыОстатки.ДатаПроведения УБЫВ
	|ИТОГИ
	|	МАКСИМУМ(Количество),
	|	МАКСИМУМ(Сумма),
	|	СУММА(КолОст),
	|	СУММА(СумОст)
	|ПО
	|	Номенклатура";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени);
	
	Если НЕ МетодСписания = Перечисления.УчетнаяПолитика.ЛИФО Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст,"УБЫВ","");
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока Выборка.Следующий() Цикл
		
		Разница = Выборка.Количество - Выборка.КолОст;
		Если Разница > 0 Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "Недостаточно номенклатуры "+Выборка.Номенклатура+" в количестве "+Разница;
			Сообщение.Сообщить();
			Отказ = Истина;
			Возврат;
		КонецЕсли;
		
		ОсталосьСписать = Выборка.Количество;
		
		ВыборкаДетальныеЗаписи = Выборка.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() И ОсталосьСписать > 0 Цикл
			
			Списать = Мин(ОсталосьСписать, ВыборкаДетальныеЗаписи.КолОст);
			
			Если ОсталосьСписать = ВыборкаДетальныеЗаписи.КолОст Тогда
				СуммаСписать = ВыборкаДетальныеЗаписи.СумОст;
			Иначе
				СуммаСписать = Списать * ВыборкаДетальныеЗаписи.СумОст / ВыборкаДетальныеЗаписи.КолОст;
			КонецЕсли;
			
			Движение = Движения.ОстаткиНоменклатуры.Добавить();
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
			Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.Количество = Списать;
			Движение.Сумма = СуммаСписать;
			
			Движение = Движения.Продажи.Добавить();
			Движение.Период = Дата;
			Движение.Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.Количество = Списать;
			Движение.Себестоимость = СуммаСписать;
			Движение.Накладная = Ссылка;
			Движение.Продажа = ВыборкаДетальныеЗаписи.Сумма;
			
			ОсталосьСписать = ОсталосьСписать - Списать;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

Функция Метод(Отказ, МоментВремени) Экспорт
	
	ЗапросМетод = Новый Запрос;
	ЗапросМетод.Текст = 	
	"ВЫБРАТЬ
	|	АктуальныйМетодСрезПоследних.Значение
	|ИЗ
	|	РегистрСведений.АктуальныйМетод.СрезПоследних(&МоментВремени, ) КАК АктуальныйМетодСрезПоследних";
	
	ЗапросМетод.УстановитьПараметр("МоментВремени", МоментВремени);
	
	РезультатЗапроса = ЗапросМетод.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не выбрана методика списания";
		Сообщение.Сообщить();
	КонецЕсли;
	
	ВыборкаМетод = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаМетод.Следующий() Цикл
		МетодСписания = ВыборкаМетод.Значение;
	КонецЦикла;
	
	Возврат МетодСписания;
	
КонецФункции

